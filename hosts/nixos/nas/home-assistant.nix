{ pkgs, ... }:

let
  # The TrueNAS VM, with the same PCI slots so the guest keeps its interface
  # name. The firmware variables start fresh, because TrueNAS's do not fit this
  # firmware build; Home Assistant OS boots from the default EFI path.
  domain = pkgs.writeText "haos.xml" ''
    <domain type='kvm'>
      <name>haos</name>
      <uuid>ab18fd5f-585c-4010-a85c-b8f68829a51b</uuid>
      <title>Home Assistant OS</title>
      <memory unit='MiB'>2048</memory>
      <vcpu placement='static'>2</vcpu>
      <os firmware='efi'>
        <type arch='x86_64' machine='pc-i440fx-10.0'>hvm</type>
        <firmware>
          <feature enabled='no' name='secure-boot'/>
        </firmware>
      </os>
      <features>
        <acpi/>
        <apic/>
      </features>
      <cpu mode='host-passthrough' check='none' migratable='on'/>
      <clock offset='localtime'/>
      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>restart</on_crash>
      <devices>
        <disk type='block' device='disk'>
          <driver name='qemu' type='raw' cache='none' io='threads' discard='unmap'/>
          <source dev='/dev/zvol/Max/VMs/haos-vm'/>
          <target dev='vda' bus='virtio'/>
          <serial>u2hZHc9s</serial>
          <boot order='1'/>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
        </disk>
        <controller type='usb' index='0' model='nec-xhci'>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
        </controller>
        <controller type='virtio-serial' index='0'>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
        </controller>
        <interface type='bridge'>
          <mac address='00:a0:98:0e:91:29'/>
          <source bridge='br0'/>
          <model type='virtio'/>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
        </interface>
        <serial type='pty'/>
        <console type='pty'>
          <target type='serial' port='0'/>
        </console>
        <channel type='unix'>
          <target type='virtio' name='org.qemu.guest_agent.0'/>
        </channel>
        <hostdev mode='subsystem' type='usb' managed='yes'>
          <source startupPolicy='optional'>
            <vendor id='0x8087'/>
            <product id='0x0032'/>
          </source>
        </hostdev>
        <memballoon model='virtio'>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
        </memballoon>
      </devices>
    </domain>
  '';
in
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
    };
  };

  users.users.michielbruins.extraGroups = [ "libvirtd" ];

  # The AX210's Bluetooth belongs to the VM.
  boot.blacklistedKernelModules = [ "btusb" ];

  systemd.services.haos = {
    description = "Home Assistant OS virtual machine";
    wantedBy = [ "multi-user.target" ];
    requires = [ "libvirtd.service" ];
    wants = [ "network-online.target" ];
    after = [
      "libvirtd.service"
      "network-online.target"
      "zfs-mount.service"
      "zfs-volumes.target"
    ];
    unitConfig.ConditionPathExists = "/dev/zvol/Max/VMs/haos-vm";
    path = [ pkgs.libvirt ];
    environment.LIBVIRT_DEFAULT_URI = "qemu:///system";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      virsh define ${domain}
      if [[ "$(virsh domstate haos)" != running ]]; then
        virsh start haos
      fi
    '';
  };

  # CI builds this with the host, so a broken definition fails there.
  system.extraDependencies = [
    (pkgs.runCommand "haos-domain-valid"
      {
        nativeBuildInputs = [
          pkgs.libvirt
          pkgs.libxml2
        ];
      }
      ''
        virt-xml-validate ${domain} domain
        touch $out
      ''
    )
  ];
}

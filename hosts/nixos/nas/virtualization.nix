{ lib, pkgs, ... }:

let
  haosNvram = "/mnt/Max/VMs/HAOS_VARS.fd";
  haosXml = pkgs.writeText "HAOS.xml" ''
    <domain type='kvm'>
      <name>HAOS</name>
      <uuid>ab18fd5f-585c-4010-a85c-b8f68829a51b</uuid>
      <title>HAOS</title>
      <description>Home Assistant OS</description>
      <memory unit='KiB'>2097152</memory>
      <currentMemory unit='KiB'>2097152</currentMemory>
      <vcpu placement='static'>2</vcpu>
      <os>
        <type arch='x86_64' machine='pc-i440fx-10.0'>hvm</type>
        <loader readonly='yes' secure='no' type='pflash' format='raw'>${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd</loader>
        <nvram template='${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd' templateFormat='raw' format='raw'>${haosNvram}</nvram>
      </os>
      <features>
        <acpi/>
        <apic/>
        <msrs unknown='ignore'/>
      </features>
      <cpu mode='host-passthrough' check='none' migratable='on'>
        <topology sockets='2' dies='1' clusters='1' cores='1' threads='1'/>
        <cache mode='passthrough'/>
      </cpu>
      <clock offset='localtime'/>
      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>destroy</on_crash>
      <devices>
        <disk type='block' device='disk'>
          <driver name='qemu' type='raw' cache='none' io='threads' discard='unmap'/>
          <source dev='/dev/zvol/Max/VMs/haos-vm'/>
          <target dev='vda' bus='virtio'/>
          <serial>u2hZHc9s</serial>
          <boot order='1'/>
        </disk>
        <controller type='usb' index='0' model='qemu-xhci'/>
        <controller type='pci' index='0' model='pci-root'/>
        <controller type='virtio-serial' index='0'/>
        <interface type='bridge'>
          <mac address='00:a0:98:0e:91:29'/>
          <source bridge='br0'/>
          <model type='virtio'/>
        </interface>
        <serial type='pty'/>
        <console type='pty'>
          <target type='serial' port='0'/>
        </console>
        <channel type='unix'>
          <target type='virtio' name='org.qemu.guest_agent.0'/>
        </channel>
        <graphics type='spice' autoport='yes' listen='127.0.0.1'>
          <listen type='address' address='127.0.0.1'/>
        </graphics>
        <video>
          <model type='qxl' heads='1' primary='yes'/>
        </video>
        <hostdev mode='subsystem' type='usb' managed='yes'>
          <source>
            <vendor id='0x8087'/>
            <product id='0x0032'/>
          </source>
        </hostdev>
        <memballoon model='virtio'/>
      </devices>
    </domain>
  '';
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = false;

  users.users.michielbruins.extraGroups = lib.mkAfter [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    libguestfs
    libvirt
  ];

  systemd.services.haos-domain = {
    description = "Define and start the HAOS virtual machine";
    after = [
      "libvirtd.service"
      "network-online.target"
      "zfs-import-Max.service"
    ];
    requires = [
      "libvirtd.service"
      "zfs-import-Max.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.libvirt ];
    unitConfig.ConditionPathExists = "/dev/zvol/Max/VMs/haos-vm";
    script = ''
      if [[ ! -f ${lib.escapeShellArg haosNvram} ]]; then
        echo "Missing preserved HAOS NVRAM at ${haosNvram}" >&2
        exit 1
      fi

      virt-xml-validate ${haosXml} domain
      virsh --connect qemu:///system define ${haosXml}
      virsh --connect qemu:///system autostart HAOS

      if [[ $(virsh --connect qemu:///system domstate HAOS) == "shut off" ]]; then
        virsh --connect qemu:///system start HAOS
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  system.build.haosXml =
    pkgs.runCommand "validated-HAOS.xml"
      {
        nativeBuildInputs = [ pkgs.libvirt ];
      }
      ''
        virt-xml-validate ${haosXml} domain
        cp ${haosXml} $out
      '';
}

{ modulesPath, ... }:

# PLACEHOLDER hardware and disk layout for the agent-host VM. The real values
# depend on the TrueNAS VM definition (phase 0 TrueNAS inventory, phase 7).
# Replace with the output of `nixos-generate-config` once the VM exists.
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # QEMU guest agent so TrueNAS can shut down and query the VM cleanly.
  services.qemuGuest.enable = true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];

  # PLACEHOLDER: create these labels when partitioning the VM disk.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];
}

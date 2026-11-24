{ pkgs, ... }:

# Intel i9-13900HX, LSI SAS3008 HBA, Intel I226-V. Recorded from the running
# machine on 24 November 2026.
{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "sd_mod"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    kernelModules = [
      "i915"
      "kvm-intel"
      "mpt3sas"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    # /dev/dri for containers that transcode.
    graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };
  };

  zramSwap.enable = true;
}

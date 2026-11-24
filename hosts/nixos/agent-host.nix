_:

# NixOS agent host: an x86_64 VM that will run devvm/Lima sandboxes with nested
# KVM and remote t3code. This is a minimal, bootable baseline.
{
  imports = [
    ../../profiles/server
    ./agent-host/hardware.nix
  ];

  networking.hostName = "agent-host";

  # UEFI boot.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };

    # Nested virtualisation for sandboxes. The physical host's CPU is an Intel
    # i9-13900HX; the VM must be given host-passthrough CPU mode.
    kernelModules = [ "kvm-intel" ];
    extraModprobeConfig = "options kvm_intel nested=1";
  };

  # /dev/kvm for nested sandboxes.
  users.users.michielbruins.extraGroups = [ "kvm" ];

  # Set once at first install; do not change afterwards.
  system.stateVersion = "26.05";
}

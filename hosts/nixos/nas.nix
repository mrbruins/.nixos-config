{ agenix, pkgs, ... }:

{
  imports = [
    ../../modules/shared
    ../../modules/shared/ssh.nix
    ../../modules/nixos/common.nix
    ./nas/containers.nix
    ./nas/hardware.nix
    ./nas/health.nix
    ./nas/identity.nix
    ./nas/networking.nix
    ./nas/samba.nix
    ./nas/secrets.nix
    ./nas/snapshots.nix
    ./nas/storage.nix
    ./nas/virtualization.nix
    ../../modules/users/michielbruins/nixos.nix
    agenix.nixosModules.default
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.michielbruins = import ../../modules/users/michielbruins/home-manager.nix;
  };

  environment.systemPackages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  system.stateVersion = "26.05";
}

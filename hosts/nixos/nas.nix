{ agenix, pkgs, ... }:

{
  imports = [
    ../../modules/shared
    ../../modules/shared/ssh.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/storage.nix
    ../../modules/nixos/nas-services.nix
    ../../modules/nixos/secrets.nix
    ../../modules/users/michielbruins/nixos.nix
    agenix.nixosModules.default
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
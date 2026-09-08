{ pkgs, ... }:

{
  time.timeZone = "Europe/Amsterdam";

  nix = {
    package = pkgs.nix;
    settings = {
      allowed-users = [ "michielbruins" ];
      trusted-users = [ "root" "@wheel" "michielbruins" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    inetutils
    tmux
  ];
}
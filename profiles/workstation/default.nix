{ pkgs, ... }:

# Home Manager profile for the machine you sit at.
{
  imports = [
    ../cli
    ./ssh.nix
  ];

  home.packages = import ./packages.nix { inherit pkgs; };
}

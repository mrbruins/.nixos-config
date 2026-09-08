{ ... }:

{
  imports = [
    ../../home-manager/shell.nix
    ../../home-manager/ssh.nix
  ];

  home = {
    username = "michielbruins";
    homeDirectory = "/home/michielbruins";
    stateVersion = "26.05";
  };

  manual.manpages.enable = false;
}
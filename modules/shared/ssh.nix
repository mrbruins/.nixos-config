{ lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
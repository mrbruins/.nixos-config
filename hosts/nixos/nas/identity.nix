{ lib, ... }:

{
  security.sudo.wheelNeedsPassword = false;
  services.openssh.settings.PermitRootLogin = lib.mkForce "no";
}

{ lib, ... }:

{
  networking = {
    hostName = "nas";
    domain = "m11s.nl";
    useDHCP = lib.mkDefault true;
    firewall.allowedTCPPorts = [ 22 ];
  };
}
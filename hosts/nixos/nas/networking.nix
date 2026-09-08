{ ... }:

{
  networking = {
    hostName = "nas";
    domain = "m11s.nl";
    useDHCP = false;

    bridges.br0.interfaces = [ "enp4s0" ];

    interfaces = {
      enp4s0.useDHCP = false;
      br0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.2.20";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a02:a458:8ff8::20";
            prefixLength = 64;
          }
        ];
      };
    };

    defaultGateway = {
      address = "192.168.2.1";
      interface = "br0";
    };
    defaultGateway6 = {
      address = "fe80::1e0b:8bff:fe18:388d";
      interface = "br0";
    };
    nameservers = [ "192.168.2.1" ];

    firewall.allowedTCPPorts = [ 22 ];
  };
}

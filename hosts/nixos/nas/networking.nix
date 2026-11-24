_:

{
  networking = {
    hostName = "nas";
    useDHCP = false;
    # The router, not AdGuard: the NAS must resolve names before its containers run.
    nameservers = [ "192.168.2.1" ];

    # Bridged traffic of the Home Assistant VM. Docker sets the FORWARD policy
    # to DROP, which can also catch it.
    firewall = {
      extraCommands = "iptables -I FORWARD -i br0 -o br0 -j ACCEPT";
      extraStopCommands = "iptables -D FORWARD -i br0 -o br0 -j ACCEPT 2>/dev/null || true";
    };
  };

  # AdGuard binds port 53 on every address.
  services.resolved.enable = false;

  systemd.network = {
    enable = true;
    wait-online.extraArgs = [ "--interface=br0" ];

    netdevs."10-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };

    networks = {
      "10-enp4s0" = {
        matchConfig.Name = "enp4s0";
        networkConfig.Bridge = "br0";
      };
      "20-br0" = {
        matchConfig.Name = "br0";
        address = [ "192.168.2.20/24" ];
        gateway = [ "192.168.2.1" ];
        networkConfig.IPv6AcceptRA = true;
        # Keeps the fixed ::20 address under whatever prefix the router announces.
        ipv6AcceptRAConfig.Token = "static:::20";
      };
    };
  };
}

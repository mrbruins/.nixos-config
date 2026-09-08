{ ... }:

{
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "192.168.2.20";
    port = 9100;
    enabledCollectors = [
      "systemd"
      "zfs"
    ];
  };

  networking.firewall.interfaces.br0.allowedTCPPorts = [ 9100 ];

  zramSwap.enable = true;
}

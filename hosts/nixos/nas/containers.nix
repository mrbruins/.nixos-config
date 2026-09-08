{ lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      ipv6 = true;
      "fixed-cidr-v6" = "fdd0::/64";
      "default-network-opts".bridge."com.docker.network.enable_ipv6" = "true";
      "default-address-pools" = [
        {
          base = "172.17.0.0/12";
          size = 24;
        }
        {
          base = "fdd0::/48";
          size = 64;
        }
      ];
    };
  };

  users.users.michielbruins.extraGroups = lib.mkAfter [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  systemd.services = {
    docker-plugin-loki = {
      description = "Install the pinned Docker Loki logging plugin";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      before = [ "docker-network-traefik-proxy.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.docker ];
      script = ''
        if ! docker plugin inspect loki:latest >/dev/null 2>&1; then
          docker plugin install \
            grafana/loki-docker-driver:3.3.2-amd64 \
            --alias loki \
            --grant-all-permissions
        elif [[ $(docker plugin inspect --format '{{.Enabled}}' loki:latest) != "true" ]]; then
          docker plugin enable loki:latest
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    docker-network-traefik-proxy = {
      description = "Create the external Traefik Docker network";
      after = [ "docker-plugin-loki.service" ];
      requires = [ "docker-plugin-loki.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.docker ];
      script = ''
        if ! docker network inspect traefik-proxy >/dev/null 2>&1; then
          docker network create \
            --driver bridge \
            --subnet 172.16.2.0/24 \
            --gateway 172.16.2.1 \
            traefik-proxy
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}

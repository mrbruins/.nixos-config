{ lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # A clone of the TrueNAS Docker directory, mounted below at the same path,
      # because containers and volumes record it. The original stays untouched.
      data-root = "/mnt/.ix-apps/docker";
      storage-driver = "overlay2";

      # Some containers talk to the socket with an older API version.
      min-api-version = "1.24";

      # Same addressing as on TrueNAS.
      ipv6 = true;
      fixed-cidr-v6 = "fdd0::/64";
      default-network-opts.bridge."com.docker.network.enable_ipv6" = "true";
      default-address-pools = [
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

  # As on TrueNAS; Redis saves need it.
  boot.kernel.sysctl."vm.overcommit_memory" = 1;

  # Stacks refer to these groups by number.
  users.groups = {
    docker.gid = lib.mkForce 999;
    render.gid = lib.mkForce 107;
  };

  users.users.michielbruins.extraGroups = [ "docker" ];

  systemd = {
    # Not in fileSystems: that would also make NixOS import the pool itself,
    # without the /mnt prefix (see storage.nix).
    mounts = [
      {
        what = "Max/docker-root";
        where = "/mnt/.ix-apps/docker";
        type = "zfs";
        requires = [ "zfs-mount.service" ];
        after = [ "zfs-mount.service" ];
      }
    ];

    # Never start with an empty directory: without the pools, do not start.
    services.docker = {
      after = [ "zfs-mount.service" ];
      unitConfig = {
        RequiresMountsFor = [ "/mnt/.ix-apps/docker" ];
        AssertPathIsMountPoint = [ "/mnt/Max/docker/data" ];
      };
    };
    sockets.docker.unitConfig.RequiresMountsFor = [ "/mnt/.ix-apps/docker" ];
  };
}

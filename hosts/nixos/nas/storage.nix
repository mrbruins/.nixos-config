{ config, ... }:

{
  networking.hostId = "11346ac0";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [
        "Lewis"
        "Max"
      ];
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  systemd = {
    services = {
      zfs-scrub-Max = {
        description = "Scrub the Max ZFS pool";
        serviceConfig.Type = "oneshot";
        path = [ config.boot.zfs.package ];
        script = "zpool scrub Max";
      };

      zfs-scrub-Lewis = {
        description = "Scrub the Lewis ZFS pool";
        serviceConfig.Type = "oneshot";
        path = [ config.boot.zfs.package ];
        script = "zpool scrub Lewis";
      };
    };

    timers = {
      zfs-scrub-Max = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-01,03,05,07,09,11-10 03:15:00";
          Persistent = true;
        };
      };

      zfs-scrub-Lewis = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-02,04,06,08,10,12-11 03:15:00";
          Persistent = true;
        };
      };
    };
  };
}

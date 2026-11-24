{ config, lib, ... }:

let
  pools = [
    "Lewis"
    "Max"
  ];
in

# Both pools keep their TrueNAS properties, so TrueNAS can import them again.
# Do not run `zpool upgrade`.
{
  # TrueNAS's host ID: the pools then do not look foreign to either system.
  networking.hostId = "11346ac0";

  boot = {
    supportedFilesystems.zfs = true;
    zfs.forceImportRoot = false;
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      inherit pools;
      interval = "monthly";
    };
    trim.enable = false;
  };

  # The datasets' mount points are /Lewis and /Max. TrueNAS imports the pools
  # with the prefix /mnt, and so must we; boot.zfs.extraPools cannot.
  systemd.services = lib.genAttrs' pools (
    pool:
    lib.nameValuePair "zfs-import-${pool}" {
      description = "Import ZFS pool ${pool} under /mnt";
      wantedBy = [ "zfs-import.target" ];
      before = [ "zfs-import.target" ];
      wants = [ "systemd-udev-settle.service" ];
      after = [
        "systemd-modules-load.service"
        "systemd-udev-settle.service"
      ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "10min";
      };
      path = [ config.boot.zfs.package ];
      script = ''
        if ! zpool list -H ${pool} >/dev/null 2>&1; then
          zpool import -d /dev/disk/by-id -N -R /mnt ${pool}
        fi
      '';
    }
  );
}

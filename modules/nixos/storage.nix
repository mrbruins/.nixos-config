{ ... }:

{
  networking.hostId = "6d313173";

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
{ ... }:

let
  shareDefaults = {
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "vfs objects" = "fruit streams_xattr";
    "fruit:metadata" = "stream";
  };
in
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "nas";
          "server role" = "standalone server";
          "map to guest" = "Bad User";
          "server min protocol" = "SMB2_02";
          "ntlm auth" = "ntlmv2-only";
        };

        videos = shareDefaults // {
          path = "/mnt/Lewis/videos";
        };
        photos = shareDefaults // {
          path = "/mnt/Lewis/photos";
        };
        Media = shareDefaults // {
          path = "/mnt/Lewis/Media";
        };
        backups = shareDefaults // {
          path = "/mnt/Lewis/backups";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}

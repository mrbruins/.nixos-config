{ ... }:

{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    nfs.server.enable = true;

    samba = {
      enable = true;
      openFirewall = true;
      settings.global = {
        workgroup = "WORKGROUP";
        "server string" = "nas";
        "server role" = "standalone server";
        "map to guest" = "Bad User";
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    smartd.enable = true;
  };
}
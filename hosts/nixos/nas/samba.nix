{ lib, ... }:

let
  shares = {
    Media = "/mnt/Lewis/Media";
    backups = "/mnt/Lewis/backups";
    photos = "/mnt/Lewis/photos";
    videos = "/mnt/Lewis/videos";
  };
in

# TrueNAS used NFSv4 ACLs, which OpenZFS on Linux ignores. Access is plain
# ownership instead: one owner, set by Samba for everything it writes. Set the
# password by hand: sudo smbpasswd -a michielbruins
{
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = false;
      settings = {
        global = {
          "server string" = "nas";
          "server min protocol" = "SMB3";
          "map to guest" = "Never";
          "vfs objects" = "catia fruit streams_xattr";
          "fruit:metadata" = "stream";
          "fruit:model" = "MacSamba";
        };
      }
      // lib.mapAttrs (_: path: {
        inherit path;
        "read only" = "no";
        "valid users" = "michielbruins";
        "force user" = "michielbruins";
        "force group" = "michielbruins";
        "create mask" = "0660";
        "directory mask" = "0770";
      }) shares;
    };

    # Finder finds the server by name.
    avahi = {
      enable = true;
      openFirewall = true;
      allowInterfaces = [ "br0" ];
      publish = {
        enable = true;
        userServices = true;
      };
      extraServiceFiles.smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

  systemd.services.samba-smbd = {
    after = [ "zfs-mount.service" ];
    unitConfig.AssertPathIsMountPoint = lib.attrValues shares;
  };
}

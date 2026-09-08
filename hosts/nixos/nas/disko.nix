{ config, ... }:

let
  systemDisk = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4762e23a";
in
{
  assertions = [
    {
      assertion = builtins.attrNames config.disko.devices.disk == [ "system" ];
      message = "NAS disko must manage only the system disk";
    }
    {
      assertion = config.disko.devices.disk.system.device == systemDisk;
      message = "NAS disko system disk does not match the verified SN850X EUI";
    }
  ];

  disko.devices.disk.system = {
    type = "disk";
    device = systemDisk;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
            extraArgs = [
              "-n"
              "ESP"
            ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            extraArgs = [
              "-L"
              "nixos"
            ];
          };
        };
      };
    };
  };
}

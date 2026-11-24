{ config, ... }:

let
  # The 1 TB SN850X TrueNAS boots from (checked 24 November 2026). Installing
  # erases it. The two 2 TB SN850X drives are the Max pool: never match by model.
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
      message = "NAS disko system disk does not match the verified disk ID";
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

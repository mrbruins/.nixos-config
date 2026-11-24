{ pkgs }:

# Pools made the way TrueNAS makes them (mount points without /mnt, imported
# with the prefix) must come up in the right place after a boot, and Docker
# must not start before they do.
pkgs.testers.runNixOSTest {
  name = "nas-storage";

  nodes.machine =
    { ... }:
    {
      imports = [
        ../hosts/nixos/nas/docker.nix
        ../hosts/nixos/nas/samba.nix
        ../hosts/nixos/nas/storage.nix
      ];

      users = {
        groups.michielbruins = { };
        users.michielbruins = {
          isNormalUser = true;
          group = "michielbruins";
        };
      };

      virtualisation = {
        memorySize = 2048;
        emptyDiskImages =
          map
            (serial: {
              size = 1024;
              driveConfig.deviceExtraOpts = { inherit serial; };
            })
            [
              "lewis"
              "max"
            ];
      };
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    with subtest("without the pools nothing starts on an empty directory"):
        machine.fail("systemctl is-active docker.service")
        machine.fail("systemctl start docker.service")
        machine.fail("systemctl is-active samba-smbd.service")

    with subtest("create the pools the way TrueNAS does"):
        machine.succeed(
            "zpool create -R /mnt -O mountpoint=/Lewis -O acltype=posix Lewis /dev/disk/by-id/virtio-lewis",
            "zfs create -o acltype=nfsv4 -o aclmode=restricted Lewis/Media",
            "zfs create Lewis/backups",
            "zfs create -o acltype=nfsv4 -o aclmode=restricted Lewis/photos",
            "zfs create -o acltype=nfsv4 -o aclmode=restricted Lewis/videos",
            "zpool create -R /mnt -O mountpoint=/Max Max /dev/disk/by-id/virtio-max",
            "zfs create -p Max/docker/data",
            "zfs create -o mountpoint=/.ix-apps -o canmount=noauto Max/ix-apps",
            "zfs create -o canmount=noauto Max/ix-apps/docker",
            "zfs mount Max/ix-apps",
            "zfs mount Max/ix-apps/docker",
            "touch /mnt/.ix-apps/docker/from-truenas /mnt/Lewis/photos/photo",
            "zfs unmount Max/ix-apps",
            "zfs snapshot Max/ix-apps/docker@before-nixos",
            "zfs clone -o mountpoint=legacy Max/ix-apps/docker@before-nixos Max/docker-root",
            "zpool export Lewis",
            "zpool export Max",
        )

    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    with subtest("pools are under /mnt"):
        machine.succeed(
            "mountpoint /mnt/Lewis/Media",
            "mountpoint /mnt/Max/docker/data",
            "test -f /mnt/Lewis/photos/photo",
            "test ! -e /Lewis && test ! -e /Max",
        )

    with subtest("Docker runs on the clone and leaves the original alone"):
        machine.wait_for_unit("docker.service")
        machine.succeed("test \"$(findmnt -no SOURCE /mnt/.ix-apps/docker)\" = Max/docker-root")
        machine.succeed("test -f /mnt/.ix-apps/docker/from-truenas")
        machine.succeed("docker info --format '{{.DockerRootDir}} {{.Driver}}' | grep -x '/mnt/.ix-apps/docker overlay2'")
        machine.succeed("test -z \"$(zfs diff Max/ix-apps/docker@before-nixos Max/ix-apps/docker)\"")

    with subtest("Samba serves the shares"):
        machine.wait_for_unit("samba-smbd.service")
        machine.succeed("testparm -s 2>/dev/null | grep -F '[photos]'")
  '';
}

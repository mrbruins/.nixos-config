{ lib, ... }:

let
  user = "michielbruins";
in

# The NAS: storage, SMB shares, Docker stacks and the Home Assistant VM.
# Install and cutover steps are in docs/nas-cutover.md.
{
  imports = [
    ../../profiles/server
    ./nas/alerts.nix
    ./nas/disko.nix
    ./nas/docker.nix
    ./nas/hardware.nix
    ./nas/home-assistant.nix
    ./nas/networking.nix
    ./nas/samba.nix
    ./nas/snapshots.nix
    ./nas/storage.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    efi.canTouchEfiVariables = true;
  };

  # Same numeric owner as on TrueNAS: the pools and the containers use it.
  users = {
    groups.${user}.gid = 3000;
    users.${user} = {
      uid = 3000;
      group = lib.mkForce user;
    };
  };

  # Set once at first install; do not change afterwards.
  system.stateVersion = "26.05";
}

{ pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in
{
  users.groups = {
    media.gid = 3001;
    michielbruins.gid = 3000;
  };

  users.users = {
    michielbruins = {
      isNormalUser = true;
      uid = 3000;
      group = "michielbruins";
      extraGroups = [
        "media"
        "wheel"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    root.openssh.authorizedKeys.keys = authorizedKeys;
  };
}

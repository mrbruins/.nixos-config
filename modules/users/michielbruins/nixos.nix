{ pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in
{
  users.users = {
    michielbruins = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    root.openssh.authorizedKeys.keys = authorizedKeys;
  };
}
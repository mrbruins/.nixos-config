{ pkgs, ... }:

let
  user = "michielbruins";
in

# NixOS profile for every server: key-only SSH, Tailscale, the CLI profile and
# one human account. Servers use reviewed, supported packages only, so this
# does not import modules/shared.
{
  networking.firewall.enable = true;

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Join by hand with `sudo tailscale up --qr`.
    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  programs.zsh.enable = true;

  users.users = {
    ${user} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      # wheel: sudo, which asks for a password. Set one on the first console login.
      extraGroups = [ "wheel" ];
      # Private key in 1Password ("SSH - TrueNAS").
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRj2sHfADZUIrwDwsLRsDCWaS8yuggc/vzQ0nh7Ht2I"
      ];
    };
    # No password login for root.
    root.hashedPassword = "!";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: pkg.pname or "" == "unrar";

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${user} = {
      imports = [ ../cli ];

      home.stateVersion = "26.05";
      manual.manpages.enable = false;
    };
  };
}

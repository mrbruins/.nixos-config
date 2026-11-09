{ pkgs, ... }:

let
  user = "michielbruins";
in

# Mac Studio (M1 Max, 64 GB): headless machine that will later serve local
# inference behind LiteLLM (implementation plan, phase 9).
#
# Deliberately minimal. Not included here, compared with the MacBook:
# - Homebrew / nix-homebrew, casks and Mac App Store apps (GUI apps).
# - Dock, trackpad, keyboard and Touch ID settings (no display or laptop).
# - agenix secrets (none needed yet).
# - The workstation package set from modules/shared/packages.nix.
#
# Not configured on purpose: SIP, Gatekeeper, FileVault, sharing services
# (Remote Login), power/sleep settings and login items. Those are part of the
# reviewed phase 9 bootstrap and stay under human control.
{
  imports = [ ../../modules/darwin/base.nix ];

  # PLACEHOLDER: confirm the real host name during the phase 9 bootstrap.
  networking.hostName = "Mac-Studio";

  environment.systemPackages = with pkgs; [
    btop
    curl
    eza
    git
    htop
    jq
    ripgrep
    tmux
  ];

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = {
      imports = [ ../../modules/home-manager/shell.nix ];

      home.stateVersion = "26.05";
      home.enableNixpkgsReleaseCheck = false;
      manual.manpages.enable = false;
    };
  };
}

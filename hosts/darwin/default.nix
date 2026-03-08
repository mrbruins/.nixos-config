{ agenix, config, lib, pkgs, ... }:

let
  user = "michielbruins";
  # Detect Determinate Nix at build time. nix-darwin is always built on the
  # local machine, so pathExists reflects the actual runtime state.
  isDeterminate = builtins.pathExists "/Library/LaunchDaemons/systems.determinate.nixd.plist";
in

{

  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
     agenix.darwinModules.default
  ];

  # When Determinate is present, hand Nix installation management to it.
  # The determinate module sets nix.enable = false, avoiding the conflict.
  determinateNix.enable = isDeterminate;

  # Standard Nix settings — only applied when nix-darwin is managing Nix
  # (i.e. on a plain Nix install without Determinate).
  nix = lib.mkIf (!isDeterminate) {
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = true;
        launchanim = true;
        orientation = "bottom";
        tilesize = 30;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}

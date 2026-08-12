{ agenix, config, lib, pkgs, ... }:

let
  user = "michielbruins";
in

{

  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
     agenix.darwinModules.default
  ];

  # Determinate manages the Nix installation; disable nix-darwin's management.
  nix.enable = false;

  services.privoxy = {
    enable = true;

    # Keep this separate from the kubectl tunnel on port 8888.
    listenAddress = "127.0.0.1:8118";

    config = ''
      # Default: connect directly to the destination.
      forward / .

      # Snowflake
      forward app.snowflake.com/                              127.0.0.1:8888
      forward .app.snowflake.com/                             127.0.0.1:8888
      forward eneco.west-europe.azure.snowflakecomputing.com/ 127.0.0.1:8888

      # Airflow
      forward airflow-test.code-102.ecsbdp.com/ 127.0.0.1:8888
      forward airflow-acc.code-102.ecsbdp.com/  127.0.0.1:8888
      forward airflow.code-002.ecsbdp.com/      127.0.0.1:8888

      # Grafana
      forward grafana.code-102.ecsbdp.com/ 127.0.0.1:8888
      forward grafana.code-002.ecsbdp.com/ 127.0.0.1:8888
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes

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

  security.pam.services.sudo_local.touchIdAuth = true;
}

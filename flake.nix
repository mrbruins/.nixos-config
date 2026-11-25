{
  description = "Michiel's machines: nix-darwin and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Stable channel for NixOS servers; see README.
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:nlewo/comin/v0.14.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.brew-src.follows = "homebrew-brew";
    };
    homebrew-brew = {
      url = "github:Homebrew/brew/7.0.12";
      flake = false;
    };
    dynatrace-oss-tap = {
      url = "github:dynatrace-oss/homebrew-tap";
      flake = false;
    };
    devvmhq-tap = {
      url = "github:devvmhq/homebrew-tap";
      flake = false;
    };
    cctm-tap = {
      url = "github:tylergraydev/homebrew-cctm";
      flake = false;
    };
    # Captures and applies macOS settings for the *-settings apps only; never
    # imported as a module, so `rig switch` doesn't apply settings. See README.
    nix-plist-manager = {
      url = "github:sushydev/nix-plist-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      comin,
      darwin,
      determinate,
      disko,
      nix-homebrew,
      homebrew-brew,
      dynatrace-oss-tap,
      devvmhq-tap,
      cctm-tap,
      home-manager,
      home-manager-stable,
      nixpkgs,
      nixpkgs-stable,
      nix-plist-manager,
    }@inputs:
    let
      user = "michielbruins";
      linuxSystems = [ "x86_64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./devshells { inherit pkgs; }
        // {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
              ];
              shellHook = with pkgs; ''
                export EDITOR=vim
              '';
            };
        };
      mkApp = scriptName: system: {
        type = "app";
        program = "${
          (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
            #!/usr/bin/env bash
            PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
            exec ${self}/apps/${system}/${scriptName} "$@"
          '')
        }/bin/${scriptName}";
      };
      # The settings apps also get the tools and paths lib/settings-common.sh expects.
      mkSettingsApp =
        scriptName: system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          npmApps = nix-plist-manager.apps.${system};
        in
        {
          type = "app";
          program = "${(pkgs.writeShellScriptBin scriptName ''
            export PATH=${
              nixpkgs.lib.makeBinPath [
                pkgs.git
                pkgs.nixfmt
              ]
            }:$PATH
            export SETTINGS_SRC=${self}/settings
            export SETTINGS_LIB=${self}/lib/macos-settings.nix
            export PLIST_KEYS=${self}/lib/plist-keys.js
            export NIXPKGS_LIB=${nixpkgs}/lib
            export NPM_ROOT=${nix-plist-manager}
            export NIX_PLIST_MANAGER_ROOT=${nix-plist-manager}
            export NPM_CURRENT=${npmApps.current.program}
            export NPM_WATCH=${npmApps.watch.program}
            exec ${self}/apps/${system}/${scriptName} "$@"
          '')}/bin/${scriptName}";
        };
      mkDarwinApps = system: {
        "bootstrap" = mkApp "bootstrap" system;
        "rig" = mkApp "rig" system;
        "rollback" = mkApp "rollback" system;
        "pin-known-good" = mkApp "pin-known-good" system;
        "capture-settings" = mkSettingsApp "capture-settings" system;
        "settings-diff" = mkSettingsApp "settings-diff" system;
        "apply-settings" = mkSettingsApp "apply-settings" system;
        "settings-watch" = mkSettingsApp "settings-watch" system;
      };
      mkDarwinSystem =
        modules:
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs;
          modules = [
            determinate.darwinModules.default
            home-manager.darwinModules.home-manager
          ]
          ++ modules;
        };
      darwinConfiguration = mkDarwinSystem [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            inherit user;
            enable = true;
            taps = {
              "dynatrace-oss/homebrew-tap" = dynatrace-oss-tap;
              "devvmhq/homebrew-tap" = devvmhq-tap;
              "tylergraydev/homebrew-cctm" = cctm-tap;
            };
            extraEnv.HOMEBREW_ORIGINAL_BREW_FILE = "/opt/homebrew/bin/brew";
            mutableTaps = false;
            autoMigrate = true;
          };
        }
        ./hosts/darwin/MacBook-Pro-Michiel.nix
      ];
      macStudioConfiguration = mkDarwinSystem [
        comin.darwinModules.comin
        ./hosts/darwin/Mac-Studio.nix
      ];
      mkNixosSystem =
        modules:
        nixpkgs-stable.lib.nixosSystem {
          modules = [
            comin.nixosModules.comin
            home-manager-stable.nixosModules.home-manager
          ]
          ++ modules;
        };
      nasConfiguration = mkNixosSystem [
        disko.nixosModules.disko
        ./hosts/nixos/nas.nix
      ];
      agentHostConfiguration = mkNixosSystem [ ./hosts/nixos/agent-host.nix ];
      # The CLI profile on a Linux machine this repository does not manage.
      mkLinuxHome =
        system:
        home-manager-stable.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-stable {
            inherit system;
            config.allowUnfreePredicate = pkg: pkg.pname or "" == "unrar";
          };
          modules = [
            ./profiles/cli
            {
              home = {
                username = user;
                homeDirectory = "/home/${user}";
                stateVersion = "26.05";
              };
              programs.home-manager.enable = true;
              manual.manpages.enable = false;
            }
          ];
        };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      darwinConfigurations = {
        "MacBook-Pro-Michiel" = darwinConfiguration;
        "Mac-Studio" = macStudioConfiguration;
        "aarch64-darwin" = darwinConfiguration;
      };

      nixosConfigurations = {
        "agent-host" = agentHostConfiguration;
        "nas" = nasConfiguration;
      };

      homeConfigurations = {
        "${user}@x86_64-linux" = mkLinuxHome "x86_64-linux";
        "${user}@aarch64-linux" = mkLinuxHome "aarch64-linux";
      };

      # One closure per host, built by CI on a matching runner.
      checks = {
        aarch64-darwin = {
          "MacBook-Pro-Michiel" = darwinConfiguration.config.system.build.toplevel;
          "Mac-Studio" = macStudioConfiguration.config.system.build.toplevel;
        };
        x86_64-linux = {
          "agent-host" = agentHostConfiguration.config.system.build.toplevel;
          "nas" = nasConfiguration.config.system.build.toplevel;
          "nas-alerts" = import ./tests/nas-alerts.nix { pkgs = nixpkgs-stable.legacyPackages.x86_64-linux; };
          "nas-storage" = import ./tests/nas-storage.nix {
            pkgs = nixpkgs-stable.legacyPackages.x86_64-linux;
          };
          "linux-cli" = self.homeConfigurations."${user}@x86_64-linux".activationPackage;
        };
      };
    };
}

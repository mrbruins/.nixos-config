{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
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
    secrets = {
      url = "git+ssh://git@github.com/mrbruins/nix-secrets.git";
      flake = false;
    };
  };
  outputs =
    {
      self,
      darwin,
      determinate,
      nix-homebrew,
      homebrew-brew,
      dynatrace-oss-tap,
      devvmhq-tap,
      home-manager,
      nixpkgs,
      agenix,
      secrets,
    }@inputs:
    # outputs = { self, darwin, determinate, home-manager, nixpkgs, agenix, secrets } @inputs:
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
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
                age
                age-plugin-yubikey
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
            echo "Running ${scriptName} for ${system}"
            exec ${self}/apps/${system}/${scriptName}
          '')
        }/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "rollback" = mkApp "rollback" system;
      };
      darwinConfiguration = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              inherit user;
              enable = true;
              taps = {
                "dynatrace-oss/homebrew-tap" = dynatrace-oss-tap;
                "devvmhq/homebrew-tap" = devvmhq-tap;
              };
              extraEnv.HOMEBREW_ORIGINAL_BREW_FILE = "/opt/homebrew/bin/brew";
              mutableTaps = false;
              autoMigrate = true;
            };
          }
          ./hosts/darwin/MacBook-Pro-Michiel.nix
        ];
      };
    in
    {
      devShells = forAllSystems devShell;
      apps =
        nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      darwinConfigurations = {
        "MacBook-Pro-Michiel" = darwinConfiguration;
        "aarch64-darwin" = darwinConfiguration;
      };
    };
}

{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nas.url = "github:nixos/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager-nas = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-nas";
    };
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
      url = "github:Homebrew/brew/5.1.10";
      flake = false;
    };
    dynatrace-oss-tap = {
      url = "github:dynatrace-oss/homebrew-tap";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
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
      home-manager,
      home-manager-nas,
      nixpkgs,
      nixpkgs-nas,
      disko,
      agenix,
      secrets,
    }@inputs:
    # outputs = { self, darwin, determinate, home-manager, nixpkgs, disko, agenix, secrets } @inputs:
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
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }
          ./hosts/darwin/MacBook-Pro-Michiel.nix
        ];
      };
      nasConfiguration = nixpkgs-nas.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          home-manager-nas.nixosModules.home-manager
          ./hosts/nixos/nas.nix
        ];
      };
    in
    {
      devShells = forAllSystems devShell;
      apps =
        nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      checks.x86_64-linux = {
        nas = nasConfiguration.config.system.build.toplevel;
        nas-haos-xml = nasConfiguration.config.system.build.haosXml;
      };

      darwinConfigurations = {
        "MacBook-Pro-Michiel" = darwinConfiguration;
        "aarch64-darwin" = darwinConfiguration;
      };

      nixosConfigurations.nas = nasConfiguration;
    };
}

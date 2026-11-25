{
  config,
  lib,
  pkgs,
  ...
}:

# Home Manager profile for every machine: shell, editor, tools and the
# seven-day cooldown for package managers (docs/adr/0003-seven-day-cooldown.md).
{
  programs = lib.mkMerge [
    (import ./programs.nix { inherit config lib pkgs; })
    {
      # Enters a project's devshell when you cd into it.
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        # A devshell sets some sixty variables; do not list them on every cd.
        config.global.hide_env_diff = true;
      };
    }
  ];

  home = {
    packages = import ./packages.nix { inherit pkgs; };

    file = {
      # npm 11+: days.
      ".npmrc".text = ''
        registry=https://registry.npmjs.org/
        min-release-age=7
      '';

      # Bun: seconds.
      ".bunfig.toml".text = ''
        [install]
        minimumReleaseAge = 604800
      '';

      ".config/uv/uv.toml".text = ''
        exclude-newer = "7 days"
      '';
    };
  };
}

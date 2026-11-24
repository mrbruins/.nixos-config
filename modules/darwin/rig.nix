{
  config,
  lib,
  pkgs,
  ...
}:

let
  apps = ../../apps/aarch64-darwin;
  names = list: lib.concatMapStringsSep "\n" (item: item.name) list + "\n";
  declared = pkgs.linkFarm "rig-declared" {
    brews = pkgs.writeText "brews" (names config.homebrew.brews);
    casks = pkgs.writeText "casks" (names config.homebrew.casks);
  };
  rig = pkgs.writeShellScriptBin "rig" ''
    export RIG_APPS=${apps}
    ${lib.optionalString config.homebrew.enable "export RIG_DECLARED=${declared}"}
    exec ${apps}/rig "$@"
  '';
in
{
  environment.systemPackages = [ rig ];
}

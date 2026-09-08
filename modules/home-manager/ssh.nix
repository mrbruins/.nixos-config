{ config, lib, pkgs, ... }:

let
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
in
{
  home.file = lib.filterAttrs
    (name: _: lib.hasPrefix ".ssh/" name || lib.hasPrefix ".config/ssh/" name)
    sharedFiles;
}
{ config, lib, pkgs, ... }:

{
  programs = import ../shared/home-manager.nix {
    inherit config lib pkgs;
  };
}
{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  colima
  cfspeedtest
  # TODO: move node to shared-packages?
  nodejs_24
]

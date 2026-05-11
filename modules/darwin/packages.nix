{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  docker-client  # Docker CLI for use with Lima socket
  lima
  git-credential-manager

  opencode
  
  # colima
  # cfspeedtest # build broken
  # TODO: move node to shared-packages?
  nodejs_24
  dotnet-sdk_9
]

{ pkgs }:

# Command-line tools every machine has. Language runtimes and anything tied to
# a desktop belong in ../workstation/packages.nix.
with pkgs;
[
  # Shell and system
  bash-completion
  btop
  coreutils
  eza
  fastfetch
  htop
  iftop
  killall
  nano
  tree

  # Files and text
  fd
  jq
  ripgrep
  sqlite
  unrar
  unzip
  zip

  # Network and security
  age
  curl
  gnupg
  openssh
  wget

  # Development
  gh
  git
  uv
]

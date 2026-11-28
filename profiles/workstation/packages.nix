{ pkgs }:

# Runtimes and desktop tools, on top of ../cli/packages.nix.
with pkgs;
[
  # System
  dockutil
  speedtest-cli

  # Development
  claude-code
  devenv
  git-credential-manager
  nil # Nix language server (VS Code Personal - Nix profile)
  nixfmt # Nix formatter used by nil and `nix fmt`

  # Containers
  docker-client # talks to the Lima VM; see docs/docker.md. Lima itself comes with devvm.

  # Runtimes
  bun
  dotnet-sdk_10
  nodejs_24
  python314
  virtualenv

  # Cloud (the Azure CLI itself is the `azure-cli` cask in modules/darwin/casks.nix)
  az-pim-cli # Azure AD Privileged Identity Management CLI; uses the `az` login
  # Cloudflare's `cf` CLI comes from npm through `rig update`; see default.nix.

  # AI
  codebase-memory-mcp
  github-copilot-cli

  # Media and documents
  ffmpeg
  libreoffice-bin
  pandoc
  yt-dlp

  # Fonts
  font-awesome
  hack-font
  meslo-lgs-nf
  noto-fonts
  noto-fonts-color-emoji
]

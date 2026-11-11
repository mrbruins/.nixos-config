{ pkgs }:

with pkgs; [
  # System & Shell Utilities
  bash-completion
  nano
  bat             # Cat clone with syntax highlighting
  btop            # Resource monitor
  coreutils
  eza             # Modern replacement for 'ls'
  fastfetch       # Display system information
  htop            # System monitor
  iftop           # Network bandwidth monitoring
  killall         # Terminate processes by name
  speedtest-cli
  tmux            # Terminal multiplexer
  tree            # Directory tree viewer

  # Security & Encryption
  age             # Simple, modern and secure file encryption tool
  # age-plugin-yubikey
  gnupg           # GNU Privacy Guard
  # libfido2
  openssh

  # Version Control & Development Tools
  git
  gh              # GitHub CLI
  golangci-lint   # Fast Go linters runner
  devenv          # Reproducible development environments
  jq              # JSON processor
  ripgrep
  fd              # Fast alternative to 'find'
  sqlite
  uv              # Fast Python package manager

  # Networking & File Transfer
  curl
  wget

  # Archive Management
  unrar
  unzip
  zip

  # Programming Languages & Runtimes
  ## Bun (JavaScript runtime)
  bun

  ## Node.js
  nodejs_24

  ## Python
  python314
  virtualenv

  
  # Cloud & Azure (the Azure CLI itself is the `azure-cli` Homebrew cask, see modules/darwin/casks.nix)
  az-pim-cli      # Azure AD Privileged Identity Management CLI; uses the `az` login

  # Text Processing
  pandoc          # Universal document converter
  # aspell
  # aspellDicts.en
  # hunspell

  # Fonts & Typography
  font-awesome
  hack-font
  meslo-lgs-nf
  noto-fonts
  noto-fonts-color-emoji

  # Media
  ffmpeg

  # AI Tools
  github-copilot-cli

  # Commented out / reference
  # nodePackages.npm
  # nodePackages.prettier
  # python313
  # python313Packages.virtualenv
  # alacritty
  # emacs-all-the-icons-fonts
  # jetbrains-mono
  # zoxide
  # zsh-powerlevel10k
  # dejavu_fonts
]

{ pkgs }:

with pkgs; [
  # System and Shell Utilities
  bash-completion  # Bash completion scripts
  bat             # Cat clone with syntax highlighting
  btop        # Resource monitor
  coreutils  # Core utilities
  eza        # A modern replacement for 'ls'
  htop        # System monitor
  iftop       # Network bandwidth monitoring
  killall    # Terminate processes by name
  neofetch   # Display system information
  speedtest-cli # CLI for testing internet speed
  tmux        # Terminal multiplexer
  tree        # Directory tree viewer

  # Security and Encryption
  age # Simple, modern and secure file encryption tool
  # age-plugin-yubikey # YubiKey plugin for age
  gnupg # GNU Privacy Guard for encryption and signing
  # libfido2 # FIDO2 library for hardware security keys
  openssh # SSH client and server

  # Development Tools
  gh          # GitHub CLI
  jq          # JSON processor
  ripgrep     # Search tool
  sqlite

  # Archive Management
  unrar
  unzip
  zip

  # Cloud and Containerization
  # docker
  # docker-compose
   (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])
  az-pim-cli

  # Programming Languages and Runtimes
  ## Node.js
  nodejs_24

  ## Python
  python3 # Python 3 interpreter
  virtualenv # Python virtual environment tool

  # Text Processing and Language Tools
  # aspell       # Spell checker
  # aspellDicts.en # English dictionary for aspell
  # hunspell    # Spell checker

  # File Management
  fd # A simple, fast and user-friendly alternative to 'find'
  wget # Retrieve files from the web

  # Fonts and Typography
  font-awesome
  hack-font
  meslo-lgs-nf
  noto-fonts
  noto-fonts-color-emoji

  # AI Agents & Tools
  github-copilot-cli # GitHub Copilot CLI for AI-assisted coding

  # Commented out packages for reference
  # Development
  # nodePackages.npm
  # nodePackages.prettier
  # python313
  # python313Packages.virtualenv

  # Terminal and UI
  # alacritty
  # emacs-all-the-icons-fonts
  # jetbrains-mono
  # zoxide
  # zsh-powerlevel10k

  # Media
  # dejavu_fonts
  # ffmpeg
]

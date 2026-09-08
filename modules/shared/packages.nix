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
  python311
  virtualenv

  ## Go
  go

  # Cloud & Azure
  (azure-cli.withExtensions [
    azure-cli-extensions.account
    azure-cli-extensions.ad
    azure-cli-extensions.aks-preview
    azure-cli-extensions.application-insights
    azure-cli-extensions.azure-devops
    azure-cli-extensions.azure-firewall
    # azure-cli-extensions.cosmosdb-preview
    azure-cli-extensions.costmanagement
    azure-cli-extensions.databricks
    # azure-cli-extensions.dependency-map
    # azure-cli-extensions.deploy-to-azure  # broken: imports pkg_resources, which is unavailable on python3.14
    # azure-cli-extensions.eventgrid
    # azure-cli-extensions.footprint
    # azure-cli-extensions.front-door
    azure-cli-extensions.fzf
    # azure-cli-extensions.graphservices
    azure-cli-extensions.init
    azure-cli-extensions.internet-analyzer
    azure-cli-extensions.ip-group
    # azure-cli-extensions.k8s-configuration
    # azure-cli-extensions.k8s-extension
    # azure-cli-extensions.k8s-runtime
    azure-cli-extensions.log-analytics
    azure-cli-extensions.log-analytics-solution
    # azure-cli-extensions.mongo-db
    # azure-cli-extensions.monitor-control-service
    azure-cli-extensions.networkcloud
    azure-cli-extensions.notification-hub
    azure-cli-extensions.portal
    azure-cli-extensions.purview
    azure-cli-extensions.pscloud
    azure-cli-extensions.quota
    # azure-cli-extensions.redisenterprise  # broken: redisenterprise-1.4.0 fails on python3.14
    # azure-cli-extensions.reservation
    azure-cli-extensions.resource-graph
    # azure-cli-extensions.scenario-guide
    azure-cli-extensions.self-help
    azure-cli-extensions.sentinel
    azure-cli-extensions.sftp
    azure-cli-extensions.ssh
    azure-cli-extensions.staticwebapp
    azure-cli-extensions.storage-actions
    azure-cli-extensions.storage-blob-preview
    azure-cli-extensions.storage-discovery
    azure-cli-extensions.storage-mover
    azure-cli-extensions.storage-preview
    azure-cli-extensions.storagesync
    azure-cli-extensions.subscription
    azure-cli-extensions.support
    azure-cli-extensions.virtual-network-manager
    azure-cli-extensions.virtual-wan
    azure-cli-extensions.webapp
    # azure-cli-extensions.webpubsub
    azure-cli-extensions.workload-orchestration
    azure-cli-extensions.workloads
    azure-cli-extensions.zones
  ])
  az-pim-cli      # Azure AD Privileged Identity Management CLI

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

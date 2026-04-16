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
  fastfetch   # Display system information
  speedtest-cli # CLI for testing internet speed
  tmux        # Terminal multiplexer
  tree        # Directory tree viewer

  # Security and Encryption
  age # Simple, modern and secure file encsryption tool
  # age-plugin-yubikey # YubiKey plugin for age
  gnupg # GNU Privacy Guard for encryption and signing
  # libfido2 # FIDO2 library for hardware security keys
  openssh # SSH client and server

  # Development Tools
  gh          # GitHub CLI
  jq          # JSON processor
  ripgrep     # Search tool
  uv          # Fast Python package manager
  sqlite

  # Archive Management
  unrar
  unzip
  zip

  # Cloud and Containerization
  # docker
  # docker-compose
  (azure-cli.withExtensions [ 
    azure-cli-extensions.azure-devops # Azure CLI with Azure DevOps extension
    azure-cli-extensions.account # Azure CLI with Account extension for managing Azure accounts
    azure-cli-extensions.ad # Microsoft Azure Command-Line Tools DomainServicesResourceProvider Extension
    azure-cli-extensions.aks-preview # Provides a preview for upcoming AKS featuresextension for managing Azure AD PIM resources
    azure-cli-extensions.application-insights # Azure CLI extension for managing Application Insights resources
    azure-cli-extensions.cosmosdb-preview # Azure CLI extension for managing Cosmos DB resources
    azure-cli-extensions.costmanagement # Azure CLI extension for managing Azure Cost Management resources
    azure-cli-extensions.databricks # Azure CLI extension for managing Azure Databricks resources
    azure-cli-extensions.dependency-map # Azure CLI extension for managing Dependency Map resources
    azure-cli-extensions.deploy-to-azure # Deploy to Azure using Github Actions.
    azure-cli-extensions.eventgrid # Azure CLI extension for managing Event Grid resources
    azure-cli-extensions.footprint # Azure CLI extension for managing Azure Footprint resources
    azure-cli-extensions.front-door # Azure CLI extension for managing Azure Front Door resources
    azure-cli-extensions.fzf # Azure CLI extension for fuzzy searching Azure resources
    azure-cli-extensions.graphservices # Azure CLI extension for managing Microsoft Graph resources
    azure-cli-extensions.init # Azure CLI extension for initializing new projects with best practices
    azure-cli-extensions.internet-analyzer # Azure CLI extension for analyzing internet connectivity to Azure
    azure-cli-extensions.ip-group # Azure CLI extension for managing Azure IP Groups
    # azure-cli-extensions.k8s-configuration # Azure CLI extension for managing Kubernetes configuration resources
    # azure-cli-extensions.k8s-extension # Azure CLI extension for managing Kubernetes extensions
    # azure-cli-extensions.k8s-runtime # Azure CLI extension for managing Kubernetes runtime resources
    azure-cli-extensions.log-analytics # Azure CLI extension for managing Azure Log Analytics resources
    azure-cli-extensions.log-analytics-solution # Azure CLI extension for managing Azure Log Solutions resources
    azure-cli-extensions.mongo-db # Azure CLI extension for managing Azure Cosmos DB MongoDB resources
    azure-cli-extensions.monitor-control-service # Azure CLI extension for managing Azure Monitor Control Service resources
    azure-cli-extensions.networkcloud # Azure CLI extension for managing Azure Network Cloud resources
    azure-cli-extensions.notification-hub # Azure CLI extension for managing Azure Notification Hubs resources
    azure-cli-extensions.portal # Azure CLI extension for managing Azure Portal resources
    azure-cli-extensions.purview # Azure CLI extension for managing Azure Purview resources
    azure-cli-extensions.pscloud # Azure CLI extension for managing PowerShell in Azure resources
    azure-cli-extensions.quota # Azure CLI extension for managing Azure Quota resources
    azure-cli-extensions.redisenterprise # Azure CLI extension for managing Azure Redis Enterprise resources
    azure-cli-extensions.reservation # Azure CLI extension for managing Azure Reservations resources
    azure-cli-extensions.resource-graph # Azure CLI extension for managing Azure Resource Graph resources
    azure-cli-extensions.scenario-guide # Azure CLI extension for managing Azure Scenario Guide resources
    azure-cli-extensions.self-help # Azure CLI extension for managing Azure Self-Help resources
    azure-cli-extensions.sentinel # Azure CLI extension for managing Azure Sentinel resources
    azure-cli-extensions.sftp # Azure CLI extension for managing Azure SFTP resources
    azure-cli-extensions.ssh # Azure CLI extension for managing Azure SSH resources
    azure-cli-extensions.staticwebapp # Azure CLI extension for managing Azure Static Web Apps resources
    azure-cli-extensions.storage-actions # Azure CLI extension for managing Azure Storage resources
    azure-cli-extensions.storage-blob-preview # Azure CLI extension for managing Azure Storage Blob resources
    azure-cli-extensions.storage-discovery # Azure CLI extension for managing Azure Storage Discovery resources
    azure-cli-extensions.storage-mover # Azure CLI extension for managing Azure Storage Mover resources
    azure-cli-extensions.storage-preview # Azure CLI extension for managing Azure Storage resources in preview
    azure-cli-extensions.storagesync # Azure CLI extension for managing Azure Storage Sync resources
    azure-cli-extensions.subscription # Azure CLI extension for managing Azure Subscriptions resources
    azure-cli-extensions.support # Azure CLI extension for managing Azure Support resources
    azure-cli-extensions.virtual-network-manager # Azure CLI extension for managing Azure Virtual Network Manager resources
    azure-cli-extensions.virtual-wan # Azure CLI extension for managing Azure Virtual WAN resources
    azure-cli-extensions.webapp # Azure CLI extension for managing Azure Web Apps resources
    # azure-cli-extensions.webpubsub # Azure CLI extension for managing Azure Web PubSub resources
    azure-cli-extensions.workload-orchestration # Azure CLI extension for managing Azure Workload Orchestrator resources
    azure-cli-extensions.workloads # Azure CLI extension for managing Azure Workloads resources
    azure-cli-extensions.zones # Azure CLI extension for managing Azure Availability Zones resources
    ])
  az-pim-cli # Azure AD Privileged Identity Management CLI

  # Programming Languages and Runtimes
  ## Bun (JavaScript runtime, for bunx)
  bun

  ## Node.js
  nodejs_24

  ## Python
  python311 # Python 3.11 interpreter
  # virtualenv # Python virtual environment tool

  ## Go
  go # Go programming language

  # Text Processing and Language Tools
  # aspell       # Spell checker
  # aspellDicts.en # English dictionary for aspell
  # hunspell    # Spell checker

  # File Management
  curl # Data transfer tool for fetching remote resources
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
  ffmpeg
]

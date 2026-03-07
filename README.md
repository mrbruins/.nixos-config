# nixos-config

A Nix flake managing both **macOS** (nix-darwin) and **NixOS** system configurations for `michielbruins`. Tracks `nixos-unstable`.

## Features

- Unified config shared between macOS and NixOS via `modules/shared/`
- [Home Manager](https://github.com/nix-community/home-manager) for user-level dotfiles (zsh, git, tmux, vim, etc.)
- [nix-darwin](https://github.com/LnL7/nix-darwin) for macOS system management
- [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew) for declarative Homebrew cask management
- [disko](https://github.com/nix-community/disko) for declarative NixOS disk partitioning
- [agenix](https://github.com/ryantm/agenix) for secrets management (age-encrypted, YubiKey-backed)

## Repository Structure

```
├── flake.nix               # Entry point; inputs and system outputs
├── hosts/
│   ├── darwin/             # macOS host config (networking, nix settings)
│   └── nixos/              # NixOS host config (boot, disk, networking)
├── modules/
│   ├── shared/             # Cross-platform config (packages, shell, dotfiles)
│   ├── darwin/             # macOS-only config (casks, dock, secrets)
│   └── nixos/              # NixOS-only config (packages, secrets)
├── overlays/               # Custom nixpkgs overlays (auto-loaded)
└── apps/                   # Build/deploy shell scripts per architecture
    ├── aarch64-darwin/
    ├── x86_64-darwin/
    ├── aarch64-linux/
    └── x86_64-linux/
```

## Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled
- macOS: [nix-darwin](https://github.com/LnL7/nix-darwin) bootstrapped
- SSH key at `~/.ssh/id_ed25519` (used as agenix identity for secrets)
- SSH agent running with access to the private `nix-secrets` repo

## Usage

### macOS

```bash
# First-time interactive setup
nix run .#apply

# Build and activate (day-to-day usage)
nix run .#build-switch

# Build only, no activation
nix run .#build

# Roll back to previous generation
nix run .#rollback
```

### NixOS

```bash
# Build and switch (SSH agent is forwarded to root for secrets)
nix run .#build-switch
```

### Key management

```bash
nix run .#create-keys   # Generate a new age key
nix run .#copy-keys     # Copy keys to the target machine
nix run .#check-keys    # Verify key availability
```

### Dev shell

Provides `git`, `age`, and `age-plugin-yubikey`:

```bash
nix develop
```

## Adding Packages

| What | Where |
|---|---|
| Shared CLI tool | `modules/shared/packages.nix` |
| macOS-only CLI tool | `modules/darwin/packages.nix` |
| macOS GUI app (Homebrew cask) | `modules/darwin/casks.nix` |
| NixOS-only tool | `modules/nixos/packages.nix` |
| Custom derivation / fork | New file in `overlays/` |

## Secrets

Secrets are age-encrypted and stored in a private [`nix-secrets`](https://github.com/mrbruins/nix-secrets) repo. To reference a secret:

```nix
# modules/darwin/secrets.nix or modules/nixos/secrets.nix
age.secrets."my-secret" = {
  symlink = true;
  path = "/Users/${user}/.ssh/my-secret";
  file = "${secrets}/my-secret.age";
  mode = "600";
  owner = "${user}";
};
```

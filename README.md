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

## Bootstrap — fresh Mac

The `install` script handles everything end-to-end on a brand-new Mac — no manual prerequisites needed.

```bash
# 1. Clone the repo (git must already be available via Xcode CLT — the script installs it if not)
#    Or simply run the script directly if you already have curl and git:
bash <(curl -fsSL https://raw.githubusercontent.com/mrbruins/.nixos-config/main/apps/aarch64-darwin/install)
```

> **Intel Mac?** Use the `x86_64-darwin` variant:
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/mrbruins/.nixos-config/main/apps/x86_64-darwin/install)
> ```

What the script does, step by step:

| Step | Action |
|---|---|
| 1 | Install **Xcode Command Line Tools** (`xcode-select --install`) if absent |
| 2 | Install **[Determinate Nix](https://github.com/DeterminateSystems/nix-installer)** if absent |
| 3 | **Clone** this repo (prompts for destination, default `~/Developer/nixos-config`) |
| 4 | Run **`apply`** — collects username, email, GitHub username & secrets repo name; performs token substitution across all config files |
| 5 | **SSH keys** — create new ed25519 keys or copy existing keys from a USB drive |
| 6 | Run **`build-switch`** — builds and activates the full nix-darwin configuration |

After the script finishes, open a new terminal to pick up all shell changes.

## Prerequisites (day-to-day)

- [Determinate Nix](https://github.com/DeterminateSystems/nix-installer) with flakes enabled
- SSH key at `~/.ssh/id_ed25519` (used as agenix identity for secrets)
- SSH agent running with access to the private `nix-secrets` repo

## Usage

### macOS

```bash
# Full bootstrap on a fresh Mac
nix run .#install

# First-time setup on a machine that already has Nix
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
nix run .#copy-keys     # Copy keys from USB to ~/.ssh
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

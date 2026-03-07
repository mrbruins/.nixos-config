# Nix Configuration — Copilot Instructions

## Architecture Overview

This is a **Nix flake** managing both macOS (nix-darwin) and NixOS systems for user `michielbruins`. The config is organized into three layers:

- `flake.nix` — entry point; declares all inputs and builds `darwinConfigurations` / `nixosConfigurations` for each supported system arch
- `hosts/{darwin,nixos}/default.nix` — system-level config (boot, networking, nix settings, agenix)
- `modules/{darwin,nixos,shared}/` — modular config imported by hosts

**Shared-first principle:** Most user config lives in `modules/shared/` and is imported by both Darwin and NixOS. Add new CLI tools, shell aliases, and dotfiles there unless platform-specific.

## Key Files by Purpose

| Need | File |
|---|---|
| CLI packages (both platforms) | `modules/shared/packages.nix` |
| Shell, git, tmux, vim, editor config | `modules/shared/home-manager.nix` |
| Static dotfiles / symlinks | `modules/shared/files.nix`, `modules/darwin/files.nix` |
| macOS GUI apps (Homebrew casks) | `modules/darwin/casks.nix` |
| Mac App Store apps | `modules/darwin/home-manager.nix` (`masApps`) |
| macOS Dock layout | `modules/darwin/dock/default.nix` |
| NixOS-only packages | `modules/nixos/packages.nix` |
| Disk partitioning (NixOS) | `modules/nixos/disk-config.nix` |
| Secrets (both platforms) | `modules/darwin/secrets.nix`, `modules/nixos/secrets.nix` |
| Nixpkgs patches / forks | `overlays/` |

## Developer Workflows

All build commands are Nix apps defined in `flake.nix` and backed by shell scripts in `apps/<system>/`.

```bash
# macOS — build and activate (requires sudo internally)
nix run .#build-switch

# macOS — build only, no activation
nix run .#build

# macOS — interactive first-time setup
nix run .#apply

# macOS — roll back to a previous generation
nix run .#rollback

# NixOS — build and switch (passes SSH_AUTH_SOCK to root for secrets)
nix run .#build-switch

# Dev shell (provides git, age, age-plugin-yubikey)
nix develop
```

`NIXPKGS_ALLOW_UNFREE=1` is set automatically inside the build scripts; you do not need to set it manually.

## Platform-Specific Conventions

- **macOS GUI apps** go in `modules/darwin/casks.nix` (Homebrew) or `masApps` in `modules/darwin/home-manager.nix` — never in nixpkgs for GUI apps.
- **NixOS `hosts/nixos/default.nix`** contains placeholders `%HOST%` and `%INTERFACE%` that must be substituted during first-time machine setup.
- **Overlays** in `overlays/` are auto-loaded by `modules/shared/default.nix` — any `.nix` file dropped there is applied at build time without manual imports.

## Secrets Management

Secrets use **agenix** (age encryption). Identity key is `~/.ssh/id_ed25519`. Encrypted secret files live in a separate private repo declared as the `secrets` flake input (`git+ssh://git@github.com/mrbruins/nix-secrets.git`).

To add a secret, reference it in `modules/{darwin,nixos}/secrets.nix`:
```nix
age.secrets."my-secret" = {
  symlink = true;
  path = "/Users/${user}/.ssh/my-secret";
  file = "${secrets}/my-secret.age";
  mode = "600";
  owner = "${user}";
};
```

## Adding Packages

- Shared CLI tool → append to `modules/shared/packages.nix`
- macOS-only CLI tool → append to `modules/darwin/packages.nix`
- macOS GUI app → append to `modules/darwin/casks.nix`
- NixOS-only tool → append to `modules/nixos/packages.nix`
- Custom derivation or fork → create a new overlay in `overlays/` (see `overlays/10-feather-font.nix` as a reference)

## Nixpkgs Channel

Tracks `nixos-unstable`. The `user` variable (`michielbruins`) is defined locally at the top of each file that needs it — this is intentional and consistent across the codebase.

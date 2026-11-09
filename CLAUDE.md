# .nixos-config

Nix flake for Michiel's machines: nix-darwin for `MacBook-Pro-Michiel` and `Mac-Studio`, and NixOS for `agent-host` (a VM on TrueNAS SCALE). The README covers layout, outputs, bootstrap and day-to-day commands. This file covers what the README does not: how to change the repo safely.

## Ground rules

- **Build, never activate.** Agents evaluate and build. Activation (`build-switch`, `darwin-rebuild switch`, `nixos-rebuild switch`, `apply`, `install`, `rollback`) is a human action. Machines will later deploy `main` by pulling it, so reviewed merges to `main` are the only path to a running system.
- **Public repository.** Everything committed here is world-readable, including the Nix store paths it produces. Secrets live only as agenix files in the private `nix-secrets` input (`secrets` in `flake.nix`) and are referenced by path in `modules/darwin/secrets.nix`. Public keys and hostnames are fine.
- **Branch and PR.** Work on a branch and open a PR against `main`. CI (`.github/workflows/nix-checks.yml`) must pass. Never push to `main` directly.

## Structure conventions

- Hosts in `hosts/<platform>/` are explicit composition roots, and `flake.nix` wires each one up. Imports are always explicit, with one exception: every file in `overlays/` is auto-loaded by `modules/shared/common.nix`.
- `modules/darwin/base.nix` holds the settings both Macs share. `hosts/darwin/default.nix` is the MacBook's workstation layer on top of it (agenix secrets, Home Manager with casks and dock, workstation packages). `Mac-Studio` imports only `base.nix`, because it is deliberately headless and minimal.
- `agent-host` deliberately skips `modules/shared`, because that module enables `allowBroken` and `allowUnsupportedSystem`. Keep server hosts on reviewed, supported packages. It tracks `nixpkgs-stable`, while the Macs track `nixos-unstable`.
- Files marked as placeholders (the `agent-host` hardware and disk labels, the `Mac-Studio` hostname) stay placeholders until real inventory replaces them. Write down any assumption you make rather than inventing hardware facts.

## Verifying a change

Run these from the repo root, as fits the change:

1. `nix flake check --all-systems --no-build`: evaluates every host and check.
2. `nix build .#checks.aarch64-darwin.<host>`: builds a Darwin host on a Mac. `x86_64-linux` hosts build only in CI unless a remote builder is configured.
3. `nix fmt -- <changed .nix files>`: formats only what you touched.
4. For a refactor that should not change behaviour, compare `nix eval --raw .#darwinConfigurations.MacBook-Pro-Michiel.config.system.build.toplevel.outPath` before and after. An identical store path proves the change is a no-op for that host. Do the same for every host the refactor touches.

A change is done when the relevant hosts evaluate and build (or CI builds them), formatting is clean, and the README still matches the outputs and layout.

## Updating inputs

Update one input per change: `nix flake update <input>`. `nixpkgs` (unstable, used by the Macs) and `nixpkgs-stable` (used by `agent-host`) are updated and reviewed separately. Homebrew is pinned through the `homebrew-brew` input, and taps are immutable flake inputs, so a new cask tap means a new input.

# The Macs are exempt from pull-based deployment

Always-on NixOS machines (the NAS and later the agent host) pull `main` after CI has built them. The MacBook does not: its user activates any branch directly. Waiting for CI made every small change slow, and the person at the keyboard is already the review. This replaces the part of the agent platform's ADR 0002 that has every machine pull approved `main`.

The Mac Studio does not pull either. comin was tried there in November 2026 and removed, for three reasons: macOS does not let a background daemon replace app bundles; comin 0.14 does not set the system profile on macOS, so a restart goes back to the previous generation; and nix-darwin reloads comin's launchd job in the middle of the activation comin is running. Its macOS updates need a person anyway, so `rig update` runs at the machine or over SSH, from `main`.

## Consequences

The MacBook can run configuration that was never merged, so drift has to be reported instead of prevented. Agents still build and never activate. CI builds the MacBook for information only, while builds of the pulling hosts are required.

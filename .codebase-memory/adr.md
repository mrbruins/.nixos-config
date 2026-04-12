# ADR: Manage hermes-agent dependencies via Nix

## Status
Proposed

## Context
The hermes-agent install script (https://github.com/NousResearch/hermes-agent) checks for and installs several system dependencies. Since this is a Nix-managed system, these dependencies should be declared in the Nix configuration rather than installed imperatively by the script.

## Dependencies Required by hermes-agent install.sh
| Dependency | Version | Purpose | Script Function |
|---|---|---|---|
| uv | latest | Python package manager | install_uv() |
| Python | 3.11+ | Runtime for hermes-agent | check_python() |
| Git | any | Clone hermes-agent repo | check_git() |
| Node.js | 22+ | Browser tools (Playwright) | check_node() |
| ripgrep | any | Fast file search (optional) | install_system_packages() |
| ffmpeg | any | TTS voice messages (optional) | install_system_packages() |
| curl | any | Download/install scripts | implicit throughout |

## Decision
Manage all hermes-agent system dependencies through the Nix configuration separately from hermes-agent itself. Shared CLI tools go in modules/shared/packages.nix. Already-present tools (git, ripgrep, nodejs) are verified. Missing tools (uv, python311, ffmpeg, curl) are added explicitly.

## Consequences
- hermes-agent install script can skip dependency installation when run with --no-venv --skip-setup
- All dependencies are reproducible and declarative
- Updates are managed through nixpkgs channel updates
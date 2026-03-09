## Shared
Much of the code running on MacOS or NixOS is actually found here.

This configuration gets imported by both modules. Some configuration examples include `git`, `zsh`, `vim`, and `tmux`.

## Layout
```
.
├── config             # Config files not written in Nix
├── cachix             # Defines cachix, a global cache for builds
├── default.nix        # Defines how we import overlays
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # The goods; most all shared config lives here
├── packages.nix       # List of packages to share

```

## ZSH Configuration

ZSH is configured in `home-manager.nix` under `programs.zsh` and is shared by both macOS and NixOS. Platform-specific layers are applied on top via `lib.recursiveUpdate` in the respective platform `home-manager.nix`.

### Initialization (`initContent`)

The `initContent` block is prepended to `.zshrc` at shell startup:

- Sources the Nix daemon profile scripts (`nix-daemon.sh`, `nix.sh`) when `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` exists — required on macOS with Determinate Nix
- Extends `PATH` with `~/.pnpm-packages/bin`, `~/.npm-packages/bin`, `~/bin`, `~/.local/share/bin`, `~/.local/bin`
- Sets `HISTIGNORE="pwd:ls:cd"` to suppress trivial entries from history
- Defines a `shell()` helper function: `nix-shell '<nixpkgs>' -A <package>`

### Shell Aliases

All aliases are declared in `shellAliases` and managed declaratively by Home Manager.

**File listing** — all powered by [`eza`](https://github.com/eza-community/eza):

| Alias | Flags | Description |
|---|---|---|
| `ls` | `-ha --icons --git --group-directories-first` | All files with icons and git status |
| `lz` | `--icons --git --group-directories-first` | Normal listing with icons |
| `l` | `-lbhF -a --icons --git` | Long format, all files |
| `ll` | `-lah --icons --git` | Long format, human-readable |
| `llm` | `-lah … --sort=modified` | Long format, sorted by modification time |
| `la` | `-lbhHigUmuSa …` | Full extended metadata |
| `lx` | `-lbhHigUmuSa@ …` | Extended metadata including xattrs |
| `tree` | `--tree` | Directory tree view |

**bat-powered replacements**:

| Alias | Tool | Description |
|---|---|---|
| `cat` | `bat` | Syntax-highlighted file output |
| `man` | `batman` | Man pages rendered via bat |
| `diff` | `batdiff` | Diff output via bat |

**Navigation** — backed by [`zoxide`](https://github.com/ajeetdsouza/zoxide):

| Alias | Command |
|---|---|
| `..` | `z ..` |
| `...` | `z ../..` |
| `....` | `z ../../..` |
| `.....` | `z ../../../..` |
| `......` | `z ../../../../..` |

**Search**:

| Alias | Command | Notes |
|---|---|---|
| `search` | `rg -p --glob '!node_modules/*'` | Ripgrep with node_modules excluded |

### Integrations

- **zoxide** (`zoxide.enableZshIntegration = true`): initialises `z` and `zi` in ZSH; acts as a smart `cd` replacement that learns frequently visited directories
- **bat** + bat-extras: provides `batdiff`, `batman`, `batwatch`, `prettybat`, `batpipe`

## Layout
```
.
├── config             # Config files not written in Nix
├── default.nix        # Defines module, system-level config,
├── disk-config.nix    # Disks, partitions, and filesystems
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # Defines user programs
├── packages.nix       # List of packages to install for NixOS
├── secrets.nix        # Age-encrypted secrets with agenix
```

## ZSH on NixOS

ZSH configuration on NixOS has two layers.

### System level (`hosts/nixos/default.nix`)

```nix
programs.zsh.enable = true;
```

This is a NixOS module option that registers ZSH in `/etc/shells` and activates the system-level ZSH setup. It must be set at the system level for ZSH to be usable as a login shell on NixOS.

The user's default login shell is then set explicitly:

```nix
users.users.${user}.shell = pkgs.zsh;
```

### User level (`home-manager.nix`)

The NixOS Home Manager config imports the shared programs directly:

```nix
programs = shared-programs // { gpg.enable = true; };
```

All shared ZSH configuration (aliases, init script, zoxide, bat integrations) is inherited unchanged. GPG is additionally enabled here for commit signing on NixOS.

For the full detail of what is configured (aliases, PATH setup, integrations), see `modules/shared/README.md`.


## Layout
```
.
├── dock               # MacOS dock configuration
├── casks.nix          # List of homebrew casks
├── default.nix        # Defines module, system-level config
├── files.nix          # Non-Nix, static configuration files (now immutable!)
├── home-manager.nix   # Defines user programs
├── packages.nix       # List of packages to install for MacOS
```

## ZSH on macOS

ZSH is set as the login shell for the user in `home-manager.nix`:

```nix
users.users.${user}.shell = pkgs.zsh;
```

On top of the shared ZSH config (see `modules/shared/README.md`), macOS merges additional settings via `lib.recursiveUpdate`:

### Extra aliases

| Alias | Command | Purpose |
|---|---|---|
| `docker` | `lima nerdctl` | Route Docker CLI calls through Lima |
| `nerdctl` | `lima nerdctl` | Direct nerdctl via Lima |

### Session variables

| Variable | Value | Purpose |
|---|---|---|
| `DOCKER_HOST` | `unix://$HOME/.lima/docker/sock/docker.sock` | Point Docker client at Lima's UNIX socket |

### SSH agent (1Password)

The shared SSH config unconditionally adds an `IdentityAgent` pointing at 1Password's agent socket on macOS:

```
IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

This means SSH operations (including `git push`) are authenticated via 1Password on macOS without any additional configuration.

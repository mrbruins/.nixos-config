# Secrets live only in 1Password

1Password is the single source of secrets: the desktop app and its SSH agent on workstations, a scoped service-account token on each server, and Connect only for containers. agenix and the private `nix-secrets` input are removed. They held no declared secrets, and their private key had to be on a machine before it could be built, so a blank machine could not bootstrap itself.

## Considered options

- **agenix or sops-nix:** works offline and keeps secrets versioned with the configuration, but adds a second place to rotate and a key to distribute first.
- **1Password Connect everywhere:** Connect runs on the NAS, so machines would depend on the NAS to boot or recover it.

## Consequences

Building and activating a machine needs no secret at all. A service that needs one starts only after its token is placed by hand, and reading a new secret needs 1Password to be reachable.

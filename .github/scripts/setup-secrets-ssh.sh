#!/usr/bin/env bash
# Give Nix read access to the private `secrets` flake input
# (git+ssh://git@github.com/mrbruins/nix-secrets.git) in CI.
# Expects NIX_SECRETS_DEPLOY_KEY: the private half of a read-only deploy key.
set -euo pipefail

if [[ -z "${NIX_SECRETS_DEPLOY_KEY:-}" ]]; then
  echo "::error::Repository secret NIX_SECRETS_DEPLOY_KEY is not set; the private 'secrets' input cannot be fetched. See README.md, section CI." >&2
  exit 1
fi

ssh_dir="$HOME/.ssh"
install -d -m 700 "$ssh_dir"

key_file="$ssh_dir/nix_secrets_deploy_key"
umask 077
printf '%s\n' "$NIX_SECRETS_DEPLOY_KEY" >"$key_file"

# GitHub's published ed25519 host key (https://api.github.com/meta), pinned
# instead of trusting ssh-keyscan on first use.
printf '%s\n' 'github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl' \
  >>"$ssh_dir/known_hosts"

cat >>"$ssh_dir/config" <<CONFIG
Host github.com
  User git
  IdentityFile $key_file
  IdentitiesOnly yes
  StrictHostKeyChecking yes
CONFIG

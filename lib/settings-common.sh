# shellcheck shell=bash
# Shared by apps/aarch64-darwin/{capture-settings,settings-diff,apply-settings,settings-watch}.
# Sourced, not run. The flake's mkSettingsApp wrapper exports:
#   SETTINGS_SRC    the flake's own settings/ (what apply-settings applies)
#   SETTINGS_LIB    lib/macos-settings.nix
#   PLIST_KEYS      lib/plist-keys.js
#   NIXPKGS_LIB     nixpkgs' lib, for evaluating SETTINGS_LIB
#   NPM_ROOT        the pinned nix-plist-manager source
#   NPM_CURRENT     nix-plist-manager's `current` app
#   NPM_WATCH       nix-plist-manager's `watch` app

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

say() { printf "${YELLOW}%s${NC}\n" "$*" >&2; }
ok() { printf "${GREEN}%s${NC}\n" "$*" >&2; }
die() {
  printf "${RED}%s${NC}\n" "$*" >&2
  exit 1
}

# Settings live per host; the Mac's own name picks the file unless --host is given.
# shellcheck disable=SC2034 # used by the scripts that source this
host=$(/usr/sbin/scutil --get LocalHostName)

# A Nix string literal for a path, safe for any characters.
nixPath() { printf '(/. + "%s")' "$(printf '%s' "$1" | sed 's/[\\"$]/\\&/g')"; }

settingsEval() {
  nix --extra-experimental-features 'nix-command flakes' eval --raw --impure --expr \
    "(import $(nixPath "$SETTINGS_LIB") { lib = import $(nixPath "$NIXPKGS_LIB"); }).$1"
}

plistKeys() { /usr/bin/osascript -l JavaScript "$PLIST_KEYS" "$@"; }

# The repo checkout this command was started from; capture and diff work on it.
checkout() {
  git rev-parse --show-toplevel 2>/dev/null || die "Run this from a checkout of the nixos-config repo."
}

# Entries of settings/apps/manifest as "domain glob...", without comments.
manifestEntries() {
  [ -f "$1" ] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^[[:space:]]*$' || true
}

# Export an app's preferences domain to a plist file. `defaults` resolves a
# sandboxed app's container itself; a container the terminal may not read (TCC)
# makes this fail.
exportDomain() { /usr/bin/defaults export "$1" "$2" 2>/dev/null; }

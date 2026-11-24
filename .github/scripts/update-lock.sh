#!/usr/bin/env bash
# Move each branch-tracking flake input to the newest revision that has been
# public on its branch for at least COOLDOWN_DAYS, one commit per input.
# docs/adr/0003-seven-day-cooldown.md
#
# Age counts from when GitHub saw the push, not from the commit date, which its
# author can set. Channel branches only ever point at revisions Hydra built, so
# the result is also in the binary cache.
#
# Inputs pinned to a tag or a FlakeHub version are left alone: they need a
# person (determinate has to match apps/aarch64-darwin/bootstrap).
set -euo pipefail

COOLDOWN_DAYS="${COOLDOWN_DAYS:-7}"
DRY_RUN="${DRY_RUN:-}"
# Inputs whose `ref` is a tag, not a branch.
PINNED=" disko homebrew-brew "

cutoff="$(date -u -d "$COOLDOWN_DAYS days ago" +%Y-%m-%dT%H:%M:%SZ)"
echo "Newest revisions public since before $cutoff"

api() { curl -fsSL --retry 3 ${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} "https://api.github.com/$1"; }

while read -r input node; do
  read -r type owner repo ref rev modified < <(
    jq -r --arg n "$node" '.nodes[$n] | [
      .original.type, (.original.owner // "-"), (.original.repo // "-"), (.original.ref // "-"),
      (.locked.rev // "-"), (.locked.lastModified // 0)
    ] | map(tostring) | join(" ")' flake.lock
  )
  if [[ "$type" != github || "$PINNED" == *" $input "* ]]; then
    echo "$input: pinned by hand, skipped"
    continue
  fi
  [[ "$ref" != - ]] || ref="$(api "repos/$owner/$repo" | jq -r .default_branch)"

  # Newest first. A force push or a deleted and recreated branch can hide what
  # was public before it, so only take what is still on the branch.
  target="$(
    api "repos/$owner/$repo/activity?ref=refs/heads/$ref&per_page=100&time_period=year" \
      | jq -r --arg cutoff "$cutoff" \
        '[.[] | select(.timestamp <= $cutoff) | select(.activity_type != "branch_deletion")][0].after // empty'
  )"
  if [[ -z "$target" ]]; then
    echo "$input: no push old enough in the last year, skipped"
    continue
  fi
  if [[ "$target" == "$rev" ]]; then
    echo "$input: up to date"
    continue
  fi
  # ahead: the target contains the locked revision. Anything else would go back
  # or sideways.
  status="$(api "repos/$owner/$repo/compare/$rev...$target?per_page=1" | jq -r .status)"
  if [[ "$status" != ahead ]]; then
    echo "$input: ${target:0:8} is $status of locked ${rev:0:8} ($(date -u -d "@$modified" +%F)), skipped"
    continue
  fi
  on_branch="$(api "repos/$owner/$repo/compare/$target...$ref?per_page=1" | jq -r .status)"
  if [[ "$on_branch" != ahead && "$on_branch" != identical ]]; then
    echo "$input: ${target:0:8} is no longer on $ref, skipped"
    continue
  fi

  echo "$input: ${rev:0:8} -> ${target:0:8}"
  [[ -z "$DRY_RUN" ]] || continue
  nix flake lock --override-input "$input" "github:$owner/$repo/$target"
  git commit --quiet --message "Update $input to ${target:0:8}" -- flake.lock
done < <(jq -r '.nodes.root.inputs | to_entries[] | "\(.key) \(.value)"' flake.lock)

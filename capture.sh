#!/usr/bin/env bash
# dotfiles/capture.sh — refresh generated/derived files in the repo.
# Managed configs are symlinked, so edits to them are already versioned here;
# this only regenerates lists that cannot be symlinked. Commits are left to
# you (prefer small atomic commits).

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"
[ -d .git ] || { echo "run from the dotfiles repo"; exit 1; }

regen() { # regen <out file>
  local out="$1"; shift
  if "$@" > "$out.$$" 2>/dev/null; then
    mv "$out.$$" "$out"; echo "refreshed $out"
  else
    rm -f "$out.$$"; echo "skipped $out (command failed)"
  fi
}

regen runtime/pacman-explicit.txt pacman -Qqe
regen runtime/aur-packages.txt pacman -Qqem

echo "--- managed (symlinked) files are already in sync. Check 'git status' and commit atomically."
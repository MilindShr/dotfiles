#!/usr/bin/env bash
# bin/verify-dev-env.sh — verify a dotfiles-installed machine.
# Safe on any device; never mutates anything.
#
#   ./bin/verify-dev-env.sh            # installed checks only (temp/owned devices)
#   ./bin/verify-dev-env.sh --secrets  # installed + secrets/auth (OWN machines only)
#
# Exit 1 if any check fails.

set -u

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="installed"
[ "${1:-}" = "--secrets" ] && MODE="secrets"

FAILS=0
pass() { printf '\033[32m[pass]\033[0m %s\n' "$*"; }
fail() { printf '\033[31m[FAIL]\033[0m %s\n' "$*"; FAILS=$((FAILS + 1)); }
check() { # check <desc> <command...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

# A representative config path per managed area; resolved symlink must point
# into the repo.
LINK_EXPECTED=(
  "shell/bashrc              $HOME/.bashrc"
  "shell/starship.toml       $HOME/.config/starship.toml"
  "editors/nvim              $HOME/.config/nvim"
  "terminals/alacritty       $HOME/.config/alacritty"
  "terminals/herdr/config.toml $HOME/.config/herdr/config.toml"
  "terminals/tmux            $HOME/.config/tmux"
  "omarchy/shell.json        $HOME/.config/omarchy/shell.json"
  "hypr/hyprland.lua         $HOME/.config/hypr/hyprland.lua"
)
for entry in "${LINK_EXPECTED[@]}"; do
  repopart="${entry%% *}"
  dst="${entry##* }"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$REPO_DIR/$repopart" ]; then
    pass "link $dst"
  else
    fail "link $dst (expected -> $REPO_DIR/$repopart)"
  fi
done

echo "--- toolchain ---"
for tool in node pnpm python uv claude codex opencode gh tmux alacritty herdr starship; do
  check "on PATH: $tool" command -v "$tool"
done

check "nvim boots (headless)" nvim --headless +q

echo "--- skills ---"
n_skills=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | wc -l)
[ "$n_skills" -ge 20 ] && pass "skills symlinked ($n_skills)" || fail "skills symlinked (found $n_skills)"

if [ "$MODE" = "secrets" ]; then
  echo "--- secrets/auth (own machine) ---"
  check "bitwarden CLI present" command -v bw
  if command -v bw >/dev/null 2>&1; then
    status=$(bw status --raw 2>/dev/null || echo n-a)
    [ "$status" = "unlocked" ] && pass "bitwarden vault unlocked" || fail "bitwarden vault locked (state: $status)"
  fi
  check "git identity set" bash -c 'test -n "$(git config --get user.name)" && test -n "$(git config --get user.email)"'
  check "github ssh auth" bash -c 'ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com 2>&1 | grep -q "successfully authenticated"'
  check "gh cli authenticated" bash -c 'gh auth status >/dev/null 2>&1'
  if [ -f "$HOME/.aws/credentials" ] || [ -f "$HOME/.aws/config" ]; then
    check "aws sts identity" bash -c 'aws sts get-caller-identity >/dev/null 2>&1'
  else
    pass "aws credentials not present (skipped)"
  fi
fi

echo
if [ "$FAILS" -gt 0 ]; then
  printf '\033[31m%d check(s) FAILED\033[0m\n' "$FAILS"
  exit 1
fi
printf '\033[32mall checks passed\033[0m\n'
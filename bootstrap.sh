#!/usr/bin/env bash
# dotfiles/bootstrap.sh — install dotfiles on a Linux machine.
# Idempotent; safe to re-run; existing files are backed up, never clobbered.
#
#   ./bootstrap.sh                 # dotfiles + skills (default)
#   ./bootstrap.sh --install       # also install missing CLIs (borrowed devices)
#   ./bootstrap.sh --with-secrets  # + SSH/AWS/GitHub from Bitwarden (OWN MACHINES ONLY)
#   ./bootstrap.sh --dry-run       # preview, change nothing
#
# --with-secrets refuses unless DOTFILES_TRUSTED=1 is set. Secrets stay on
# personal machines — never run the secrets step on borrowed hardware.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=false
WITH_SECRETS=false
INSTALL=false
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=true ;;
    --with-secrets) WITH_SECRETS=true ;;
    --install) INSTALL=true ;;
  esac
done

say() { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# Map repo-relative paths to absolute home paths. Platform: Linux only.
dest() { # dest <repo_rel_path> -> echo absolute location
  case "$1" in
    shell/zshrc)                        echo "$HOME/.zshrc" ;;
    shell/bashrc)                       echo "$HOME/.bashrc" ;;
    shell/.XCompose)                    echo "$HOME/.XCompose" ;;
    shell/starship.toml)                echo "$HOME/.config/starship.toml" ;;
    git/config)                         echo "$HOME/.config/git/config" ;;
    editors/nvim)                       echo "$HOME/.config/nvim" ;;
    editors/terminals/alacritty)        echo "$HOME/.config/alacritty" ;;
    editors/terminals/herdr/config.toml) echo "$HOME/.config/herdr/config.toml" ;;
    tmux)                               echo "$HOME/.config/tmux" ;;
    agents/claude/themes)               echo "$HOME/.claude/themes" ;;
    agents/opencode/opencode.json)      echo "$HOME/.config/opencode/opencode.json" ;;
    agents/codex/config.toml)           echo "$HOME/.codex/config.toml" ;;
    agents/codex/rules)                 echo "$HOME/.codex/rules" ;;
    platform/linux/omarchy/shell.json)  echo "$HOME/.config/omarchy/shell.json" ;;
    platform/linux/omarchy/*)           echo "$HOME/.config/omarchy/${1#platform/linux/omarchy/}" ;;
    platform/linux/hypr/*)              echo "$HOME/.config/hypr/${1#platform/linux/hypr/}" ;;
    skills/*)                           echo "$HOME/.agents/skills/$(basename "$1")" ;;
    bin/*)                              echo "$HOME/.local/bin/$(basename "$1")" ;;
    *) echo "" ;;
  esac
}

link() { # link <repo_rel_path>
  local src="$REPO_DIR/$1"
  local dst="$(dest "$1")"
  [ -n "$dst" ] || { warn "no mapping for $1"; return; }
  [ -e "$src" ] || { warn "missing in repo: $1"; return; }
  [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ] && return
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak="$dst.dotfiles-$(date +%s).bak"
    warn "existing '$dst' -> back up to $bak"
    $DRY || mv "$dst" "$bak"
  fi
  mkdir -p "$(dirname "$dst")"
  $DRY && { say "would link: $dst -> $1"; return; }
  ln -s "$src" "$dst"
  say "linked: $dst"
}

link_shell() {
  [ -f "$REPO_DIR/shell/zshrc" ] && link shell/zshrc
  [ -f "$REPO_DIR/shell/bashrc" ] && link shell/bashrc
  [ -f "$REPO_DIR/shell/starship.toml" ] && link shell/starship.toml
  [ -f "$REPO_DIR/shell/.XCompose" ] && link shell/.XCompose
  say "shell: rc/prompt linked"
}

link_editor() {
  [ -f "$REPO_DIR/git/config" ] && link git/config
  [ -d "$REPO_DIR/editors/nvim" ] && link editors/nvim
  [ -d "$REPO_DIR/editors/terminals/alacritty" ] && link editors/terminals/alacritty
  [ -f "$REPO_DIR/editors/terminals/herdr/config.toml" ] && link editors/terminals/herdr/config.toml
  [ -d "$REPO_DIR/tmux" ] && link tmux
  say "editors/terminals linked"
}

link_bin() {
  if [ -d "$REPO_DIR/bin" ]; then
    for f in "$REPO_DIR"/bin/*; do
      [ -f "$f" ] || continue
      link "bin/$(basename "$f")"
    done
    say "CLI wrappers linked to ~/.local/bin"
  fi
}

link_agents() {
  [ -d "$REPO_DIR/agents/claude/themes" ] && link agents/claude/themes
  [ -f "$REPO_DIR/agents/opencode/opencode.json" ] && link agents/opencode/opencode.json
  [ -f "$REPO_DIR/agents/codex/config.toml" ] && link agents/codex/config.toml
  [ -d "$REPO_DIR/agents/codex/rules" ] && link agents/codex/rules
  say "agent configs linked"
}

link_skills() {
  if [ -d "$REPO_DIR/skills" ]; then
    for s in "$REPO_DIR"/skills/*; do
      [ -d "$s" ] || continue
      name="$(basename "$s")"
      mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills"
      for root in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
        dst="$root/$name"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$s" ]; then continue; fi
        if [ -e "$dst" ] || [ -L "$dst" ]; then
          warn "existing '$dst' -> back up"; $DRY || mv "$dst" "$dst.dotfiles-$(date +%s).bak"
        fi
        if $DRY; then say "would link: $dst"; else
          ln -s "$s" "$dst"; say "linked: $dst"
        fi
      done
    done
  fi
}

link_platform() {
  [ -f "$REPO_DIR/platform/linux/omarchy/shell.json" ] && link platform/linux/omarchy/shell.json
  for d in branding hooks extensions backgrounds; do
    [ -d "$REPO_DIR/platform/linux/omarchy/$d" ] && link "platform/linux/omarchy/$d"
  done
  for f in hyprland.conf hyprland.lua .luarc.json monitors.conf monitors.lua \
           input.conf input.lua bindings.conf bindings.lua looknfeel.conf looknfeel.lua \
           autostart.conf autostart.lua hypridle.conf hyprlock.conf hyprsunset.conf \
           envs.conf xdph.conf; do
    [ -e "$REPO_DIR/platform/linux/hypr/$f" ] && link "platform/linux/hypr/$f"
  done
  say "omarchy/hypr customizations linked"
}

cmd_hint() { # cmd_hint <binary> [package name(s)]
  local bin="$1"; shift
  command -v "$bin" >/dev/null 2>&1 && return
  say "$bin not found — install with one of:"
  echo "    pacman -S $*      (Arch / omarchy)"
  echo "    sudo apt install $*"
  echo "    sudo dnf install $*"
}

install_tools() {
  if ! command -v mise >/dev/null 2>&1; then
    say "installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
  say "installing CLI tools from runtime/mise/config.toml (claude, codex, opencode, gh, ...)"
  $DRY && { say "would run: mise install"; return; }
  eval "$(mise activate bash 2>/dev/null)" || true
  mise install -y || true
  cmd_hint nvim nvim
  say "done. If the new CLIs aren't on PATH, start a new shell."
}

restore_secrets() {
  command -v bw >/dev/null 2>&1 || { warn "bitwarden-cli not found — skipping secrets"; exit 0; }
  echo "Unlocking Bitwarden... (master password + 2FA)"
  export BW_SESSION="$(bw unlock --raw 2>/dev/null)" || { warn "unlock failed"; exit 1; }

  note() { # note <vault item name> <dest file> <perms>
    local content
    content="$(bw get note "$1" 2>/dev/null)" || { warn "vault item '$1' not found — SKIP"; return; }
    mkdir -p "$(dirname "$2")"
    printf '%s\n' "$content" > "$2"
    chmod "$3" "$2"
    say "restored $2"
  }

  note "dotfiles-ssh-id_ed25519"     "$HOME/.ssh/id_ed25519" 600
  note "dotfiles-ssh-id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub" 644
  note "dotfiles-aws-credentials"    "$HOME/.aws/credentials" 600
  note "dotfiles-aws-config"         "$HOME/.aws/config" 600
  if command -v gh >/dev/null 2>&1; then
    if [ -n "$(bw get note dotfiles-github-token 2>/dev/null)" ]; then
      bw get note dotfiles-github-token | gh auth login --with-token && say "gh authenticated"
    fi
  fi
  echo "Add SSH key to the agent:  ssh-add $HOME/.ssh/id_ed25519 (enter passphrase)"
}

main() {
  say "repo: $REPO_DIR  (home: $HOME)"
  link_shell
  link_editor
  link_bin
  link_agents
  link_skills
  link_platform
  $INSTALL && install_tools
  if $WITH_SECRETS; then
    if [ "${DOTFILES_TRUSTED:-0}" != "1" ]; then
      echo "Refusing: --with-secrets requires DOTFILES_TRUSTED=1. Secrets belong on personal machines only." >&2
      exit 1
    fi
    restore_secrets
  fi
  say "done."
}

main
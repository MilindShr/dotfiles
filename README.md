# dotfiles

Personal dotfiles for a disposable-laptop workflow: a fresh machine is rebuilt
from this repo + a Bitwarden login, with no access to previous hardware.

**This repo is PUBLIC. It contains no secrets and never should.** All
credentials live in Bitwarden (see `SECRETS-CHECKLIST.md`).

## What's here

| Path | Contents |
|------|----------|
| `shell/` | `.zshrc`, `.bashrc`, `starship.toml` prompt |
| `git/` | global git config (aliases, diff/rerere settings) |
| `editors/` | vscode, zed (themes), nvim (LazyVim), terminals (ghostty, alacritty) |
| `agents/` | claude (CLAUDE.md, settings, themes), opencode (config), codex (portable config, rules) |
| `skills/` | agent skills (shared by claude/codex/opencode via symlinks) |
| `platform/linux/` | omarchy + hyprland **customizations** (shell bar, hooks, backgrounds, hypr overrides) |
| `runtime/` | mise tools, pacman/aur package lists |
| `tmux/` | tmux.conf |
| `notes/` | memory / context notes |

Managed files are **symlinked** into place by `bootstrap.sh`, so editing them
on any machine immediately updates the repo — the repo never rots outdated by
drift.

## Fresh-machine bootstrap (the whole point)

1. Install git (+ optional `bitwarden-cli`).
2. `git clone <this repo> ~/dotfiles`
3. `~/dotfiles/bootstrap.sh`
4. For secrets: `~/dotfiles/bootstrap.sh --with-secrets` (unlock Bitwarden once)

That's it: prompt, editors, terminals, agent configs + skills, omarchy/hypr
customizations. `aws`/`ssh`/`gh` come from the vault; browser tabs/sessions
come from your Mozilla account.

Run `bootstrap.sh --dry-run` to preview. It is idempotent — re-running never
duplicates, and existing files are backed up (not clobbered).

## Staying current

- Config edits land in the repo automatically (symlinks).
- `./capture.sh` regenerates the derived lists (installed packages, vscode
  extensions).
- Keep it tidy: one logical change per commit.

## OS-agnostic

Layout is platform-neutral; only `dest()` in `bootstrap.sh` maps paths, and it
currently handles Linux (XDG). Add macOS (`~/Library/Application Support/...`)
and Windows (`%APPDATA%`) cases there when needed — config file *contents*
stay the same.
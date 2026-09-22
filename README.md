# dotfiles

A versioned developer environment that rebuilds itself on any Linux machine
— mine or a borrowed one — from this repo alone. Secrets never live here.

## Structure

- `shell/`     zsh/bash rc, starship prompt, XCompose
- `editors/`   nvim (LazyVim), alacritty, herdr, tmux
- `agents/`    claude, opencode, codex configs
- `skills/`    agent skills (symlinked into ~/.agents/skills & ~/.claude/skills)
- `bin/`       CLI launchers (claude, codex, opencode, gh, ...)
- `platform/`  linux: omarchy + hyprland customizations
- `runtime/`   mise tools, package inventories, foreign-device install notes

## Setup on my machine

1. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
2. `~/dotfiles/bootstrap.sh --with-secrets`
   (requires `DOTFILES_TRUSTED=1`; unlocks Bitwarden for ssh/aws/gh)

## Setup on a borrowed device

1. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
2. `~/dotfiles/bootstrap.sh --install` — links configs + skills, installs CLIs.

The secrets step can never run here — `--with-secrets` is refused unless
`DOTFILES_TRUSTED=1` is set. See `runtime/install-foreign.md`.

## Keeping it current

- Configs are symlinks: edits land in the repo, so commit atomically.
- `./capture.sh` refreshes the derived package lists (`runtime/`).

`bootstrap.sh` is idempotent. Preview with `--dry-run`; existing files are
backed up, never clobbered. Credentials belong to Bitwarden
(`SECRETS-CHECKLIST.md`).
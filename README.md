# dotfiles

A versioned developer environment that rebuilds itself on any machine, with this repository as the source of truth.

Because there are two kinds of developer machines: aggressively customized ones that nobody else but yourself knows how to operate, and bare-bones ones that you eventually forget how to operate.

This repository solves the gap between them with a simple, elegant strategy: override their configs, install an unreasonable amount of software, replace perfectly serviceable defaults with tools nobody has heard of, and then provide three lines of instructions explaining how to undo it.

So "I don't know how to use this machine" becomes "I don't know how to use this machine".

Same problem. Just not "**your**" problem.

Everything is versioned. Everything is reproducible. Nothing is sacred.

## Structure

- `shell/`     bash rc, starship prompt
- `editors/`   nvim
- `terminals/` alacritty, herdr, tmux
- `agents/`    claude, opencode, codex configs
- `skills/`    agent skills (symlinked into ~/.agents/skills & ~/.claude/skills)
- `bin/`       CLI launchers + `verify-dev-env.sh` (migration check)
- `hypr/`      hyprland lua config, hyprsunset + xdph
- `omarchy/`   linux desktop: shell.json, hooks, branding, backgrounds
- `runtime/`   mise tools, package inventories

## Setup on your machine

1. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
2. `DOTFILES_TRUSTED=1 ~/dotfiles/bootstrap.sh --with-secrets`
   (unlocks Bitwarden for ssh/aws/github)
3. `~/dotfiles/bin/verify-dev-env.sh --secrets` — all checks pass

## Setup on a victim

1. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
2. `~/dotfiles/bootstrap.sh --install` — links configs + skills, installs CLIs.
3. `~/dotfiles/bin/verify-dev-env.sh`

The secrets step can never run here - `--with-secrets` is refused unless
`DOTFILES_TRUSTED=1` is set.

The full ordered procedure for either case lives in **[`RUNBOOK.md`](RUNBOOK.md)**.

## Keeping it current

- Configs are symlinks: edits land in the repo, so commit atomically.
- `./capture.sh` refreshes the derived package lists (`runtime/`).

`bootstrap.sh` is idempotent. Preview with `--dry-run`; existing files are
backed up, never clobbered. Credentials belong to Bitwarden
(`SECRETS-CHECKLIST.md`).

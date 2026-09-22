# Installing on a foreign Linux device (a day's work)

Goal: pull this repo, get a working dev environment quickly, leave no trace
required. **The secrets step never runs on borrowed hardware.**

1. Install git if missing (distro package manager).
2. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
3. `~/dotfiles/bootstrap.sh --install`

`--install` links all configs + skills + CLI wrappers, then installs the CLI
toolchain with mise. It touches **only** the paths listed in `bootstrap.sh`
and never requests, reads, or writes credentials.

## What installs by itself

- `mise` (configured in `runtime/mise/config.toml`) and through it the
  tools in that config: claude, codex, opencode, gh, grok, pi, crush, ghui …
- CLI launchers in `bin/` resolve through mise (`mise use -g <pkg>` on first
  run), so no system installs are needed for the agent CLIs.

## What may still be missing (distro-dependent)

| Tool | pacman (Arch) | apt (Debian/Ubuntu) | dnf (Fedora) |
|------|---------------|---------------------|--------------|
| neovim (for LazyVim) | `sudo pacman -S neovim` | `sudo apt install neovim` | `sudo dnf install neovim` |

LazyVim also needs `git` and a Nerd Font.

## Note

Original files on the host are backed up to `*.dotfiles-<timestamp>.bak`
before a symlink replaces them — nothing is silently clobbered, and `--dry-run`
previews it all before any change.
# RUNBOOK — rebuild a developer machine

A scripted, ordered procedure: from a fresh Linux box to a working development
environment in ~20–30 minutes. **Done = `verify-dev-env.sh --secrets` exits 0**
on your own machine (`--installed` on a temp device).

## Ownership boundaries

| Layer | Owned by |
|---|---|
| OS, desktop, base packages | omarchy installer (drives the package set) |
| User config, skills, CLI launchers | this repo (`bootstrap.sh`) |
| SSH/AWS/GitHub secrets | Bitwarden vault (`--with-secrets`) |
| Code | your GitHub projects (clone manually, on demand) |
| Browsers are data | Firefox account sync (tabs/history/passwords) |
| Docs | OneDrive |

This repo owns only the second row. Never hand it secrets — it's public.

## Path A — your own (fresh) machine

1. Install omarchy on the device (per its docs). Reboot into a session.
2. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
3. `DOTFILES_TRUSTED=1 ~/dotfiles/bootstrap.sh --with-secrets`
   - Unlock Bitwarden when prompted; SSH/AWS/GitHub are restored from the vault.
   - If isolated from your ssh key passphrase, run `ssh-add ~/.ssh/id_ed25519`.
4. Start a new terminal (picks up PATH/mise from the linked rc).
5. `~/dotfiles/bin/verify-dev-env.sh --secrets` — **all checks must pass** (exit 0).
6. App logins: 1Password/Bitwarden desktop, Firefox → sign in to your account,
   OneDrive. Restore operator-specific things (VPN, company SSO) as needed.
7. Clone the projects you need from GitHub and let each project's own
   dependency files bring its toolchain (mise/npm/uv) in.
8. Optional refinement: `diff <(pacman -Qqe) <(sort ~/dotfiles/runtime/pacman-explicit.txt)`
   and cherry-pick packages the omarchy base didn't ship.

## Path B — a temp/borrowed device (never keep state)

1. `git clone https://github.com/MilindShr/dotfiles ~/dotfiles`
2. `~/dotfiles/bootstrap.sh --install` — links configs + skills, installs the
   CLI toolchain (mise). Touches only the paths listed in `bootstrap.sh`.
3. `~/dotfiles/bin/verify-dev-env.sh` — installed checks only.

The secrets step cannot run here: `--with-secrets` refuses unless `DOTFILES_TRUSTED=1`
is set, which you never set on borrowed hardware.

## Discipline

- `bootstrap.sh` is idempotent: re-running is safe; existing files are backed
  up (`*.dotfiles-<ts>.bak`), never clobbered. Preview any change with `--dry-run`.
- Before a real migration, rehearse Path A once in a VM and time it. The
  runbook is only as trustworthy as its last full execution.
- Keep config truthful: edits land in the repo (symlinks), so commit atomically.
  Refresh `runtime/` inventories with `./capture.sh` when you add/remove packages.

## Deliberately out of scope

- Company VPN / private registry / SSO creds — added per contract, iterate.
- Client-project toolchains — each project pins its own (`.mise.toml`,
  `package.json`, etc.); the global mise base is just a common floor.
- Machine state (session history, browser profiles) — distilled to configs,
  never copied.
# Memory

Context carried from the previous machine (2026-09-22 migration). This is the
distilled session context — raw agent transcripts were intentionally dropped;
skills + configs + this note are the durable form.

## Agent/tool inventory

- **Shell**: zsh + bash, starship prompt.
- **AI CLIs** (via `mise`, all "latest"): `claude`, `codex`, `opencode`,
  `gh`, `pi`, `crush`, `grok`, `ghui`, `oh-my-pi`.
- **Agent skills** live in `skills/` here and are symlinked into `~/.agents/skills`
  and `~/.claude/skills` by bootstrap. Source packs: matt pocock engineering
  skills, graphify, playwright-cli, payload (agents-only), plus ponytail
  (opencode plugin, also enabled in codex).
- **Codex**: gpt-5.6-terra, plugins enabled (browser, caveman, ponytail,
  google-calendar, slack, pdf/spreadsheets/presentations, etc.) — portable
  config in `agents/codex/config.toml`.
- **Claude**: `settings.json` enables `superpowers@claude-plugins-official`;
  note on fresh machines that plugin must be installed by the CLI before the
  setting takes effect.
- **Editors**: VS Code, Zed (aether theme), Neovim (LazyVim).
- **Terminals**: ghostty (primary), alacritty, kitty, foot.
- **Secrets system**: Bitwarden is the single vault; SSH/AWS/GH restored by
  `bootstrap.sh --with-secrets`. Browser sessions via Mozilla account.

## GitHub identity

- user: `MilindShr` — email `milinds@techkraftinc.com`.

## Conventions

- Keep `dotfiles/` public and secret-free; commit atomically.
- Run `capture.sh` when packages/extensions change.
- OS-agnostic: only `dest()` in `bootstrap.sh` maps paths; configs stay clean.
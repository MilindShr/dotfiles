# Secrets checklist — create these in Bitwarden

`bootstrap.sh --with-secrets` restores each item below via `bw get note <name>`.
The vault is the single source of truth: **nothing secret ever goes in this
repo** (it's public). A fresh machine needs only your Bitwarden login.

## Required secure notes (exact names)

| Vault item (name) | Contents | Written to | Perms |
|---|---|---|---|
| `dotfiles-ssh-id_ed25519` | the private key file contents, header and trailer included | `~/.ssh/id_ed25519` | 600 |
| `dotfiles-ssh-id_ed25519.pub` | public key text | `~/.ssh/id_ed25519.pub` | 644 |
| `dotfiles-aws-config` | your `~/.aws/config` content | `~/.aws/config` | 600 |
| `dotfiles-aws-credentials` | your `~/.aws/credentials` content | `~/.aws/credentials` | 600 |
| `dotfiles-github-token` | fine-grained PAT (repo + workflow scopes) | piped to `gh auth login` | — |

Note: keys are stored as plaintext in the vault. Protect the vault with strong
2FA; optionally encrypt with an SSH passphrase and keep the passphrase in a
separate vault item.

## Hardening (do once, they reduce what needs copying at all)

- **AWS**: switch to `aws sso` (IAM Identity Center) — then no long-lived
  credentials circulate, and this checklist shrinks to nothing for AWS.
- **SSH**: prefer passphrase-protected keys added to `ssh-agent`; consider
  short-lived certs (`ssh-askpass` + CA) for hosts that support them.
- **GitHub**: fine-grained, scoped tokens only (repo scope is enough for clone
  + issue/PR).
- Rotate anything that ever touched the old (already-public-history) dotfiles
  repo: the old `.codex/auth.json` and session logs were committed publicly
  before this migration. Treat those tokens as compromised.
---
summary: "CLI reference for `promptx doctor` (health checks + guided repairs)"
read_when:
  - You have connectivity/auth issues and want guided fixes
  - You updated and want a sanity check
title: "doctor"
---

# `promptx doctor`

Health checks + quick fixes for the gateway and channels.

Related:

- Troubleshooting: [Troubleshooting](/gateway/troubleshooting)
- Security audit: [Security](/gateway/security)

## Examples

```bash
promptx doctor
promptx doctor --repair
promptx doctor --deep
```

Notes:

- Interactive prompts (like keychain/OAuth fixes) only run when stdin is a TTY and `--non-interactive` is **not** set. Headless runs (cron, Telegram, no terminal) will skip prompts.
- `--fix` (alias for `--repair`) writes a backup to `~/.promptx/promptx.json.bak` and drops unknown config keys, listing each removal.

## macOS: `launchctl` env overrides

If you previously ran `launchctl setenv PROMPTX_GATEWAY_TOKEN ...` (or `...PASSWORD`), that value overrides your config file and can cause persistent “unauthorized” errors.

```bash
launchctl getenv PROMPTX_GATEWAY_TOKEN
launchctl getenv PROMPTX_GATEWAY_PASSWORD

launchctl unsetenv PROMPTX_GATEWAY_TOKEN
launchctl unsetenv PROMPTX_GATEWAY_PASSWORD
```

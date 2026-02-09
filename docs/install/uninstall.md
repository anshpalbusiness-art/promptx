---
summary: "Uninstall PromptX completely (CLI, service, state, workspace)"
read_when:
  - You want to remove PromptX from a machine
  - The gateway service is still running after uninstall
title: "Uninstall"
---

# Uninstall

Two paths:

- **Easy path** if `promptx` is still installed.
- **Manual service removal** if the CLI is gone but the service is still running.

## Easy path (CLI still installed)

Recommended: use the built-in uninstaller:

```bash
promptx uninstall
```

Non-interactive (automation / npx):

```bash
promptx uninstall --all --yes --non-interactive
npx -y promptx uninstall --all --yes --non-interactive
```

Manual steps (same result):

1. Stop the gateway service:

```bash
promptx gateway stop
```

2. Uninstall the gateway service (launchd/systemd/schtasks):

```bash
promptx gateway uninstall
```

3. Delete state + config:

```bash
rm -rf "${PROMPTX_STATE_DIR:-$HOME/.promptx}"
```

If you set `PROMPTX_CONFIG_PATH` to a custom location outside the state dir, delete that file too.

4. Delete your workspace (optional, removes agent files):

```bash
rm -rf ~/.promptx/workspace
```

5. Remove the CLI install (pick the one you used):

```bash
npm rm -g promptx
pnpm remove -g promptx
bun remove -g promptx
```

6. If you installed the macOS app:

```bash
rm -rf /Applications/PromptX.app
```

Notes:

- If you used profiles (`--profile` / `PROMPTX_PROFILE`), repeat step 3 for each state dir (defaults are `~/.promptx-<profile>`).
- In remote mode, the state dir lives on the **gateway host**, so run steps 1-4 there too.

## Manual service removal (CLI not installed)

Use this if the gateway service keeps running but `promptx` is missing.

### macOS (launchd)

Default label is `bot.molt.gateway` (or `bot.molt.<profile>`; legacy `com.promptx.*` may still exist):

```bash
launchctl bootout gui/$UID/bot.molt.gateway
rm -f ~/Library/LaunchAgents/bot.molt.gateway.plist
```

If you used a profile, replace the label and plist name with `bot.molt.<profile>`. Remove any legacy `com.promptx.*` plists if present.

### Linux (systemd user unit)

Default unit name is `promptx-gateway.service` (or `promptx-gateway-<profile>.service`):

```bash
systemctl --user disable --now promptx-gateway.service
rm -f ~/.config/systemd/user/promptx-gateway.service
systemctl --user daemon-reload
```

### Windows (Scheduled Task)

Default task name is `PromptX Gateway` (or `PromptX Gateway (<profile>)`).
The task script lives under your state dir.

```powershell
schtasks /Delete /F /TN "PromptX Gateway"
Remove-Item -Force "$env:USERPROFILE\.promptx\gateway.cmd"
```

If you used a profile, delete the matching task name and `~\.promptx-<profile>\gateway.cmd`.

## Normal install vs source checkout

### Normal install (install.sh / npm / pnpm / bun)

If you used `https://openclaw.ai/install.sh` or `install.ps1`, the CLI was installed with `npm install -g promptx@latest`.
Remove it with `npm rm -g promptx` (or `pnpm remove -g` / `bun remove -g` if you installed that way).

### Source checkout (git clone)

If you run from a repo checkout (`git clone` + `promptx ...` / `bun run promptx ...`):

1. Uninstall the gateway service **before** deleting the repo (use the easy path above or manual service removal).
2. Delete the repo directory.
3. Remove state + workspace as shown above.

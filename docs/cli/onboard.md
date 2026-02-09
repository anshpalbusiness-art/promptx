---
summary: "CLI reference for `promptx onboard` (interactive onboarding wizard)"
read_when:
  - You want guided setup for gateway, workspace, auth, channels, and skills
title: "onboard"
---

# `promptx onboard`

Interactive onboarding wizard (local or remote Gateway setup).

## Related guides

- CLI onboarding hub: [Onboarding Wizard (CLI)](/start/wizard)
- CLI onboarding reference: [CLI Onboarding Reference](/start/wizard-cli-reference)
- CLI automation: [CLI Automation](/start/wizard-cli-automation)
- macOS onboarding: [Onboarding (macOS App)](/start/onboarding)

## Examples

```bash
promptx onboard
promptx onboard --flow quickstart
promptx onboard --flow manual
promptx onboard --mode remote --remote-url ws://gateway-host:18789
```

Flow notes:

- `quickstart`: minimal prompts, auto-generates a gateway token.
- `manual`: full prompts for port/bind/auth (alias of `advanced`).
- Fastest first chat: `promptx dashboard` (Control UI, no channel setup).

## Common follow-up commands

```bash
promptx configure
promptx agents add <name>
```

<Note>
`--json` does not imply non-interactive mode. Use `--non-interactive` for scripts.
</Note>

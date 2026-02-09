---
summary: "CLI reference for `promptx config` (get/set/unset config values)"
read_when:
  - You want to read or edit config non-interactively
title: "config"
---

# `promptx config`

Config helpers: get/set/unset values by path. Run without a subcommand to open
the configure wizard (same as `promptx configure`).

## Examples

```bash
promptx config get browser.executablePath
promptx config set browser.executablePath "/usr/bin/google-chrome"
promptx config set agents.defaults.heartbeat.every "2h"
promptx config set agents.list[0].tools.exec.node "node-id-or-name"
promptx config unset tools.web.search.apiKey
```

## Paths

Paths use dot or bracket notation:

```bash
promptx config get agents.defaults.workspace
promptx config get agents.list[0].id
```

Use the agent list index to target a specific agent:

```bash
promptx config get agents.list
promptx config set agents.list[1].tools.exec.node "node-id-or-name"
```

## Values

Values are parsed as JSON5 when possible; otherwise they are treated as strings.
Use `--json` to require JSON5 parsing.

```bash
promptx config set agents.defaults.heartbeat.every "0m"
promptx config set gateway.port 19001 --json
promptx config set channels.whatsapp.groups '["*"]' --json
```

Restart the gateway after edits.

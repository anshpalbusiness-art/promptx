---
summary: "CLI reference for `promptx plugins` (list, install, enable/disable, doctor)"
read_when:
  - You want to install or manage in-process Gateway plugins
  - You want to debug plugin load failures
title: "plugins"
---

# `promptx plugins`

Manage Gateway plugins/extensions (loaded in-process).

Related:

- Plugin system: [Plugins](/tools/plugin)
- Plugin manifest + schema: [Plugin manifest](/plugins/manifest)
- Security hardening: [Security](/gateway/security)

## Commands

```bash
promptx plugins list
promptx plugins info <id>
promptx plugins enable <id>
promptx plugins disable <id>
promptx plugins doctor
promptx plugins update <id>
promptx plugins update --all
```

Bundled plugins ship with PromptX but start disabled. Use `plugins enable` to
activate them.

All plugins must ship a `promptx.plugin.json` file with an inline JSON Schema
(`configSchema`, even if empty). Missing/invalid manifests or schemas prevent
the plugin from loading and fail config validation.

### Install

```bash
promptx plugins install <path-or-spec>
```

Security note: treat plugin installs like running code. Prefer pinned versions.

Supported archives: `.zip`, `.tgz`, `.tar.gz`, `.tar`.

Use `--link` to avoid copying a local directory (adds to `plugins.load.paths`):

```bash
promptx plugins install -l ./my-plugin
```

### Update

```bash
promptx plugins update <id>
promptx plugins update --all
promptx plugins update <id> --dry-run
```

Updates only apply to plugins installed from npm (tracked in `plugins.installs`).

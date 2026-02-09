---
summary: "CLI reference for `promptx reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `promptx reset`

Reset local config/state (keeps the CLI installed).

```bash
promptx reset
promptx reset --dry-run
promptx reset --scope config+creds+sessions --yes --non-interactive
```

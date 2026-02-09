---
summary: "CLI reference for `promptx logs` (tail gateway logs via RPC)"
read_when:
  - You need to tail Gateway logs remotely (without SSH)
  - You want JSON log lines for tooling
title: "logs"
---

# `promptx logs`

Tail Gateway file logs over RPC (works in remote mode).

Related:

- Logging overview: [Logging](/logging)

## Examples

```bash
promptx logs
promptx logs --follow
promptx logs --json
promptx logs --limit 500
```

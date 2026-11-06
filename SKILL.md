---
name: kb-skill
description: >-
  Use this skill when the user types /kb setup or /kb refresh.
  /kb setup: Scans the entire repository to discover workflows, entry points,
  database models, Kafka topics, and API routes, then presents findings to the
  user for confirmation before building a structured .kb/ knowledge base with a
  KB_INDEX.md for deterministic AI context injection. Also interactively
  populates deps.config.yaml for cross-repo dependency knowledge extraction via
  sub-agents.
  /kb refresh: Diffs the current codebase against the existing .kb/ knowledge
  base, presents changed areas to the user, updates confirmed sections, then
  checks all deps in deps.config.yaml for staleness (TTL + commit-hash drift)
  and refreshes stale ones via cheap flash-lite sub-agents that clone, extract,
  and terminate without polluting the parent agent context.
---

# KB Skill — Repository Knowledge Base

A portable, repo-agnostic agent skill. Install once as a git submodule.
Builds and maintains a structured `.kb/` knowledge base that lets AI agents
inject precisely the right context without crawling source code.

---

## Commands

| Command | When to Use |
|---|---|
| `/kb setup` | First time — build the full `.kb/` KB for this repo |
| `/kb refresh` | After code changes or before/after an MR — keep KB current |

---

## Quick Start

**On `/kb setup` → load and follow:**
[references/kb-setup.md](./references/kb-setup.md)

**On `/kb refresh` → load and follow:**
[references/kb-refresh.md](./references/kb-refresh.md)

---

## How AI Uses the KB (Once Built)

```
1. Read .kb/KB_INDEX.md
   → map task keywords to specific .md file paths
   → load ONLY those files into context

2. If cross-repo info is needed
   → read .kb/deps/deps.config.yaml
   → find the relevant dep entry
   → check .kb/deps/<name>/META.md for freshness

3. If dep KB is fresh → load it directly (no clone)
   If dep KB is stale or missing → spawn sub-agent (flash-lite)
   Sub-agent: clone → extract → write KB files → report → terminate

4. Fallback (no KB match found)
   → load product/PRD.md + helpers/architecture/overview.md
   → then explore source code from entry-points listed in the nearest workflow
```

---

## Reference Files (load on demand — do not pre-load)

| File | Contents |
|---|---|
| [references/kb-setup.md](./references/kb-setup.md) | Full `/kb setup` protocol — scan, present, confirm, generate |
| [references/kb-refresh.md](./references/kb-refresh.md) | Full `/kb refresh` protocol — diff, update, staleness check |
| [references/sub-agent-protocol.md](./references/sub-agent-protocol.md) | Operating instructions for dep-extraction sub-agents |
| [references/freshness-strategy.md](./references/freshness-strategy.md) | TTL + commit-hash drift detection logic |
| [references/kb-structure-spec.md](./references/kb-structure-spec.md) | Canonical `.kb/` folder structure specification |

## Templates (copy into host repo during setup)

All blank KB file templates are in [templates/](./templates/).

## Scripts (run during setup and refresh)

| Script | Purpose |
|---|---|
| [scripts/detect-workflows.sh](./scripts/detect-workflows.sh) | Scan repo for controllers, CLI commands, Kafka consumers, cron jobs |
| [scripts/detect-deps.sh](./scripts/detect-deps.sh) | Scan package managers for dependency names |
| [scripts/check-freshness.sh](./scripts/check-freshness.sh) | Check TTL + git ls-remote hash drift per dep |

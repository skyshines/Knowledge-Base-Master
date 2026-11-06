# `/kb refresh` — Full Protocol

Keeps the `.kb/` knowledge base accurate as the codebase evolves.
Run manually — ideally before raising an MR and after merging from master.

---

## Pre-flight Checks

- [ ] `.kb/` exists. If not, run `/kb setup` first.
- [ ] You are at the repository root.

---

## Phase 1 — Source Code Diff Against KB

Compare current codebase state against what the KB documents.

### What to Diff

| KB Section | What to Compare Against |
|---|---|
| `workflows/*/entry-points.md` | Current controller routes, Kafka listeners, CLI commands, cron jobs |
| `workflows/*/affected-components.md` | Current imports and DB/Kafka/external client calls from entry points |
| `helpers/db-tables/` | Current ORM entity definitions |
| `helpers/kafka/topics.md` | Current Kafka producer/consumer registrations |
| `helpers/apis/README.md` | Current REST endpoint list |
| `helpers/config/env-vars.md` | Current env var references in code |

### Change Categories

Classify detected changes into:

```
ADDED       → something exists in code but is not in KB
REMOVED     → something is in KB but no longer exists in code
MODIFIED    → something exists in both but details have changed
UNCHANGED   → no diff detected
```

---

## Phase 2 — Present Changes to User

Present a clear diff summary before making any changes:

```
KB REFRESH — CHANGES DETECTED
────────────────────────────────────────────────
WORKFLOWS:
  [ADDED]    New entry point: POST /api/v1/rollback → RollbackController.java:12
             → Suggest adding to: workflows/feature-update/ or new workflow?

  [MODIFIED] workflows/assessment/entry-points.md
             → POST /api/v1/assessment changed to POST /api/v2/assessment

  [REMOVED]  workflows/download/entry-points.md references KafkaListener 'download.requested'
             → Topic no longer found in codebase. Removed?

DB TABLES:
  [ADDED]    New entity: RollbackRecord.java → no KB file exists yet

KAFKA:
  [MODIFIED] helpers/kafka/topics.md
             → New producer call: kafkaTemplate.send("rollback.initiated", ...)
               Not in topics.md

ENV VARS:
  [ADDED]    ROLLBACK_FEATURE_FLAG — found in RollbackController.java:8
────────────────────────────────────────────────
Which of these should I update? (say 'all', list numbers, or give instructions)
```

Wait for user response. Update only confirmed sections.

---

## Phase 3 — Apply KB Updates

For each confirmed change:

### Added entry point
- If it fits an existing workflow → add to that workflow's `entry-points.md` and `affected-components.md`.
- If it's a new workflow → ask user to confirm workflow name → create new folder from templates.

### Modified entry point
- Update the relevant line in `entry-points.md`.
- Check if `flow.md` steps are still accurate — flag any that may be outdated.

### Removed entry point
- Remove from `entry-points.md`.
- If the entire workflow is gone, ask: *"Should I archive or delete `workflows/<name>/`?"*

### New DB table
- Create `helpers/db-tables/<table-name>.md` from template.
- Fill in schema from ORM entity file.

### New Kafka topic
- Add to `helpers/kafka/topics.md`.

### New env var
- Add to `helpers/config/env-vars.md`.

---

## Phase 4 — Dep Staleness Check

After applying source code changes, check all deps in `deps.config.yaml` for staleness.

```bash
bash .agents/skills/kb-skill/scripts/check-freshness.sh
```

The script outputs per-dep staleness status. Present to user:

```
DEP KB FRESHNESS CHECK
────────────────────────────────────────────────
  ✅ notification-service  — fresh  (fetched 3 days ago, TTL=14d, hash unchanged)
  ⚠️  payment-service      — STALE  (fetched 7 days ago, TTL=5d)
  ⚠️  user-service         — STALE  (hash drifted: remote HEAD moved)
────────────────────────────────────────────────
Refresh stale deps? (say 'yes' / 'no' / 'only payment-service')
```

---

## Phase 5 — Dep KB Refresh via Sub-Agent

For each dep the user confirms for refresh:

1. Load [sub-agent-protocol.md](./sub-agent-protocol.md).
2. Spawn a sub-agent (flash-lite model) with:
   - The dep's full entry from `deps.config.yaml`
   - The sub-agent protocol instructions
   - The absolute path to `.kb/deps/<dep-name>/`
3. Wait for sub-agent report.
4. Confirm files were written and `META.md` was updated.

> **Parent agent context stays clean.** The sub-agent does all cloning and
> extraction. The parent only receives the structured completion report.

---

## Phase 6 — Regenerate KB_INDEX.md

After all updates are applied:
- Re-scan all workflow `entry-points.md` files for keywords.
- Re-scan all helper folders.
- Re-scan all dep META.md files.
- Rewrite `KB_INDEX.md` to reflect the current state.

---

## Phase 7 — Refresh Summary

```
✅ KB REFRESH COMPLETE
────────────────────────────────────────────────
Source KB updates:
  Modified:  2 files  (assessment/entry-points.md, kafka/topics.md)
  Added:     2 files  (db-tables/rollback-record.md, config/env-vars.md)
  Removed:   0 files

Dep KB refreshes:
  payment-service   → ✅ Refreshed  (commit: a3f82bc, next TTL: 5 days)
  user-service      → ✅ Refreshed  (commit: d91cc04, next TTL: 7 days)
  notification-service → ⏭️  Skipped (still fresh)

KB_INDEX.md → Regenerated

Commit suggestion:
  git add .kb/ && git commit -m "chore: refresh KB before MR #<number>"
────────────────────────────────────────────────
```

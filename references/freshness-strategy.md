# Freshness Strategy — Dep KB Staleness Detection

The goal is to avoid unnecessary clones while ensuring the dep KB never
silently serves outdated information.

---

## Two Signals, One Decision

A dep KB is considered **stale** if ANY of the following are true:

| Signal | Stale Condition | Config Field |
|---|---|---|
| **TTL** | `today - last_fetched > ttl_days` | `ttl_days` per dep entry |
| **Hash drift** | Remote HEAD ≠ `last_commit_hash` | Enabled when `refresh_strategy` includes `hash` |
| **Force flag** | `force_refresh: true` | `force_refresh` per dep entry |
| **Missing** | `META.md` does not exist | Always stale — first time |

---

## `refresh_strategy` Options

Set at the top of `deps.config.yaml` under `meta:`:

| Strategy | TTL Check | Hash Check | When to Use |
|---|---|---|---|
| `ttl_only` | ✅ | ❌ | Simple time-based; no network check needed |
| `hash_only` | ❌ | ✅ | Always fresh when remote is unchanged, regardless of time |
| `ttl_and_hash` *(recommended)* | ✅ | ✅ | Catches both time-based staleness and silent dep updates |
| `manual` | ❌ | ❌ | Never auto-refresh; human must run explicitly |

---

## TTL Recommendation by Dep Volatility

| Dep Change Frequency | Recommended `ttl_days` |
|---|---|
| Very active (daily deploys) | `2` |
| Normal (weekly releases) | `7` |
| Stable APIs (monthly or less) | `14` – `30` |
| Frozen / deprecated | Use `refresh_strategy: manual` |

---

## Hash Check Without Cloning

The hash check uses `git ls-remote`, which queries the remote without
downloading any objects. It is fast and cheap enough to run on every
`/kb refresh`.

```bash
# In check-freshness.sh
remote_hash=$(git ls-remote <gitlab_url> refs/heads/<branch> | cut -f1)
local_hash=$(grep 'HEAD Commit Hash' .kb/deps/<name>/META.md | awk '{print $NF}' | tr -d '`')

if [ "$remote_hash" != "$local_hash" ]; then
  echo "STALE: hash drifted ($local_hash → $remote_hash)"
fi
```

Requires SSH agent to be active (same as the clone step).

---

## Decision Flowchart

```
/kb refresh triggered
        │
        ▼
Read deps.config.yaml → for each dep:
        │
        ├─ META.md missing? ──────────────────────────→ STALE (first time)
        │
        ├─ force_refresh = true? ─────────────────────→ STALE (forced)
        │
        ├─ refresh_strategy = manual? ───────────────→ SKIP (never auto-refresh)
        │
        ├─ TTL check (if strategy includes ttl):
        │   today - last_fetched > ttl_days? ─────────→ STALE (TTL expired)
        │
        ├─ Hash check (if strategy includes hash):
        │   git ls-remote → remote HEAD ≠ local hash? → STALE (hash drifted)
        │
        └─ All checks pass ───────────────────────────→ FRESH (no action)
```

---

## Partial Dep Staleness

Each dep is evaluated independently. A single stale dep does not trigger
refresh of other deps. The user is shown the full status list and chooses
which to refresh.

---

## After Refresh

The sub-agent writes the new `last_fetched` (ISO8601) and `last_commit_hash`
back to `deps.config.yaml`. The parent agent does not need to track this
separately.

---

## Force Refresh

To force a specific dep to refresh regardless of TTL or hash:

```yaml
# In deps.config.yaml
- name: payment-service
  force_refresh: true    # ← set this
```

After `/kb refresh` runs the extraction, the sub-agent sets `force_refresh`
back to `false` automatically.

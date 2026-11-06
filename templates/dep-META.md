# META — <!-- dep-name --> KB Snapshot

| Field | Value |
|---|---|
| **Service** | <!-- dep-name --> |
| **Source Repo** | <!-- gitlab_url --> |
| **Branch** | <!-- branch --> |
| **Last Fetched** | <!-- ISO8601 timestamp --> |
| **HEAD Commit Hash** | `<!-- hash -->` |
| **TTL (days)** | <!-- ttl_days --> |
| **Stale After** | <!-- ISO8601: last_fetched + ttl_days --> |
| **Extracted By** | sub-agent (flash-lite) |
| **Refresh Reason** | <!-- FIRST_TIME / TTL_EXPIRED / HASH_DRIFT / FORCE_REFRESH / MANUAL --> |

---

## Extracted Files

| File | Contents |
|---|---|
| <!-- apis/charge-api.md --> | <!-- POST /charge, POST /refund endpoints --> |
| <!-- kafka/payment.completed.md --> | <!-- Schema + consumer notes --> |

---

## Freshness Check Logic (for AI agents)

1. Read `Last Fetched` + `TTL (days)` → compute `Stale After`.
2. If today > `Stale After` **OR** `force_refresh = true` → trigger sub-agent refresh.
3. If `refresh_strategy` includes `hash` → run `check-freshness.sh` to compare
   remote HEAD against `HEAD Commit Hash` using `git ls-remote` (no clone required).
4. If fresh → load KB files directly into context. Do NOT clone.

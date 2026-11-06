# Edge Cases & Error Handling — <!-- WORKFLOW_NAME -->

Known failure modes, edge conditions, retry strategies, and operational gotchas
for this workflow. Keep this updated — it's the AI's first reference before
suggesting error-handling code.

---

## Known Error Conditions

| Condition | Where it Occurs | Current Handling | Notes |
|---|---|---|---|
| <!-- e.g., Dep service timeout --> | <!-- Step 3 --> | <!-- retry 3x → DLQ --> | <!-- ticket / context --> |

<!-- TODO: fill from try/catch blocks, @Retryable annotations, and error handler classes -->

---

## Input Validation Failures

| Invalid Input | Validation Rule | Response / Exception |
|---|---|---|
| <!-- e.g., null entity_id --> | <!-- required, UUID format --> | <!-- 400 Bad Request / ValidationException --> |

---

## Retry & Backoff Config

| Step | Retry Count | Backoff Strategy | Backoff Config |
|---|---|---|---|
| <!-- step # or class --> | <!-- 3 --> | <!-- exponential --> | <!-- initial=1s, multiplier=2, max=30s --> |

---

## Dead Letter Queue (DLQ)

| Scenario | DLQ Topic / Queue | Consumer / Alert |
|---|---|---|
| <!-- unrecoverable failure --> | <!-- topic.name.dlq --> | <!-- manual review + replay tool --> |

---

## Idempotency

- Is this workflow idempotent? <!-- Yes / No / Partial -->
- Idempotency key: <!-- field name or 'N/A' -->
- Duplicate handling: <!-- what happens if the same event is processed twice -->

---

## Known Gotchas

<!-- Bullet list of non-obvious behaviours, historical bugs, or operational lessons -->
- <!-- TODO: add from team knowledge / runbooks -->

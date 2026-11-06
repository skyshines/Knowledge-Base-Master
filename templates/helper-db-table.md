# Table: `<!-- table_name -->`

---

## Purpose

<!-- One paragraph: what does this table store, why does it exist, which workflow(s) use it -->

---

## Schema

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | `gen_random_uuid()` | Primary key |
| `<!-- col -->` | <!-- type --> | <!-- Yes/No --> | <!-- default or — --> | <!-- description --> |
| `created_at` | TIMESTAMP | No | `NOW()` | Row creation time |
| `updated_at` | TIMESTAMP | Yes | — | Last update time |

<!-- TODO: fill from ORM entity / migration files -->

---

## Indexes

```sql
PRIMARY KEY (id)
-- TODO: add indexes from entity annotations or migration scripts
```

---

## Relationships

| Relationship | Type | Table | Column | Notes |
|---|---|---|---|---|
| <!-- owns --> | FK / referenced by | <!-- other_table --> | <!-- column --> | <!-- context --> |

---

## Access Patterns

| Query | Frequency | Index Used | Notes |
|---|---|---|---|
| Fetch by `id` | High | PK | — |
| <!-- other pattern --> | <!-- High/Med/Low --> | <!-- index name --> | <!-- context --> |

---

## Soft Delete

- Soft delete? <!-- Yes (via `deleted_at`) / No -->
- Never hard-delete? <!-- Yes / No — explain if No -->

---

## Known Gotchas

- <!-- TODO: add from team knowledge -->

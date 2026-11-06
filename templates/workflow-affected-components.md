# Affected Components — <!-- WORKFLOW_NAME -->

All modules, classes, DB tables, Kafka topics, and external services touched
by this workflow. Use this to understand the blast radius of a change.

---

## Internal Classes / Modules

| Class / File | Role in Workflow | Package / Path |
|---|---|---|
| <!-- ClassName.java --> | <!-- e.g., validates input --> | <!-- com.example.service --> |

<!-- TODO: trace from entry point imports and method calls -->

---

## Database Tables

| Table | Operation | Via (Repository / DAO) |
|---|---|---|
| <!-- table_name --> | SELECT / INSERT / UPDATE / DELETE | <!-- EntityRepository.java --> |

→ See `helpers/db-tables/<table_name>.md` for schema.

---

## Kafka Topics

| Topic | Operation | Via (Producer / Consumer class) |
|---|---|---|
| <!-- topic.name --> | produce / consume | <!-- KafkaProducer.java --> |

→ See `helpers/kafka/topics.md` for schema.

---

## External Service Calls

| Service | Operation | Client Class | Protocol |
|---|---|---|---|
| <!-- service-name --> | <!-- e.g., POST /charge --> | <!-- PaymentClient.java --> | REST / gRPC |

→ See `deps/<service-name>/apis/` for contract details.

---

## Config / Feature Flags Read

| Env Var / Flag | Purpose |
|---|---|
| <!-- ENV_VAR_NAME --> | <!-- what it controls in this workflow --> |

→ See `helpers/config/env-vars.md` for full list.

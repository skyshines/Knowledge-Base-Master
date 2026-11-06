# Entry Points — <!-- WORKFLOW_NAME -->

All triggers that initiate this workflow. The AI should reference this file
when it needs to know WHERE a workflow starts.

---

## REST Endpoints

| Method | Path | Controller | Line | Auth |
|---|---|---|---|---|
| <!-- GET/POST/PUT/DELETE --> | <!-- /api/v1/... --> | <!-- ClassName.java --> | <!-- :42 --> | <!-- JWT / API Key / none --> |

<!-- TODO: fill from controller scan -->

---

## Kafka Consumers

| Topic | Consumer Group | Consumer Class | Line | Offset Strategy |
|---|---|---|---|---|
| <!-- topic.name --> | <!-- group-id --> | <!-- ConsumerClass.java --> | <!-- :28 --> | <!-- latest / earliest --> |

<!-- TODO: fill from @KafkaListener / consumer.subscribe scan -->

---

## Scheduled / Cron Jobs

| Method | Schedule | Class | Line |
|---|---|---|---|
| <!-- methodName() --> | <!-- cron expression or @Scheduled desc --> | <!-- JobClass.java --> | <!-- :91 --> |

<!-- TODO: fill from @Scheduled / cron.AddFunc scan -->

---

## CLI Commands

| Command | Subcommand | Handler Class | Line |
|---|---|---|---|
| <!-- cli-name --> | <!-- subcommand --> | <!-- HandlerClass --> | <!-- :7 --> |

<!-- TODO: fill from CLI framework scan -->

---

## gRPC / GraphQL

| Type | Service / Resolver | Method | Handler Class | Line |
|---|---|---|---|---|
| <!-- gRPC / GraphQL --> | <!-- ServiceName --> | <!-- MethodName --> | <!-- ImplClass.java --> | <!-- :55 --> |

<!-- TODO: fill if applicable -->

# Kafka Topics — This Service

---

## Topics We Produce

| Topic | Schema / Event Class | Key Field | Partitions | Published By | When Published |
|---|---|---|---|---|---|
| <!-- topic.name --> | <!-- EventClass / .avsc --> | <!-- entity_id --> | <!-- 6 --> | <!-- ProducerClass.java --> | <!-- after workflow X completes --> |

<!-- TODO: fill from kafkaTemplate.send() / producer.produce() scans -->

---

## Topics We Consume

| Topic | Schema / Event Class | Consumer Group | Offset | Consumer Class | Workflow |
|---|---|---|---|---|---|
| <!-- topic.name --> | <!-- EventClass / .avsc --> | <!-- service-name-cg --> | <!-- latest --> | <!-- ConsumerClass.java --> | <!-- workflow name --> |

<!-- TODO: fill from @KafkaListener / consumer.subscribe() scans -->

---

## Dead Letter Queue (DLQ) Config

| Original Topic | DLQ Topic | Max Retries | DLQ Consumer |
|---|---|---|---|
| <!-- topic.name --> | <!-- topic.name.dlq --> | <!-- 3 --> | <!-- manual review + replay tool --> |

---

## Schema Registry

- Schema registry URL: <!-- https://schema-registry.example.com or 'none' -->
- Format: <!-- Avro / JSON Schema / Protobuf / plain JSON -->
- Schema evolution strategy: <!-- BACKWARD / FORWARD / FULL / none -->

---

## Consumer Group Config

| Group ID | Topics | Reset Strategy | Lag Alert Threshold |
|---|---|---|---|
| <!-- service-name-cg --> | <!-- topic.name --> | <!-- latest / earliest --> | <!-- 1000 messages --> |

→ See `consumer-groups.md` for detailed lag monitoring config.

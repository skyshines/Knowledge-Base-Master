# Environment Variables & Feature Flags

All configuration values read by this service at runtime.

---

## Application Config

| Variable | Required | Default | Description | Set In |
|---|---|---|---|---|
| `<!-- ENV_VAR -->` | Yes / No | <!-- value or none --> | <!-- what it controls --> | <!-- k8s secret / configmap / .env --> |

<!-- TODO: fill from System.getenv() / os.Getenv() / process.env / os.environ scans -->

---

## Feature Flags

| Flag Name | Type | Default | Description | Affects |
|---|---|---|---|---|
| `<!-- FLAG_NAME -->` | boolean / string / int | <!-- value --> | <!-- what it enables/disables --> | <!-- workflow name --> |

<!-- TODO: fill from feature flag client calls in codebase -->

---

## External Service URLs

| Variable | Service | Example Value |
|---|---|---|
| `<!-- PAYMENT_SERVICE_URL -->` | payment-service | `https://payment.internal.example.com` |

---

## Secrets (Do NOT log or print)

| Variable | Purpose | Rotation Policy |
|---|---|---|
| `<!-- DB_PASSWORD -->` | Database password | <!-- every 90 days via Vault --> |
| `<!-- KAFKA_SASL_PASSWORD -->` | Kafka auth | <!-- same as DB --> |

---

## Local Development

Minimum `.env` for local dev:

```bash
# Copy this to .env and fill in values
<!-- ENV_VAR_1 -->= 
<!-- ENV_VAR_2 -->= 
```

# API Endpoints — This Service

Overview of all REST endpoints exposed by this service.
For detailed per-endpoint docs, see individual `<endpoint-name>.md` files.

---

## Endpoint Index

| Method | Path | Handler Class | Auth | Description |
|---|---|---|---|---|
| <!-- GET/POST/PUT/DELETE --> | <!-- /api/v1/... --> | <!-- ClassName.java:line --> | <!-- JWT / API Key / none --> | <!-- brief description --> |

<!-- TODO: fill from controller/router scan -->

---

## Auth Schemes Used

| Scheme | Header / Mechanism | Used By |
|---|---|---|
| <!-- JWT Bearer --> | `Authorization: Bearer <token>` | <!-- most endpoints --> |
| <!-- API Key --> | `X-API-Key: <key>` | <!-- service-to-service --> |

---

## Versioning Strategy

- Current API version: <!-- v1 / v2 -->
- Version in URL: <!-- /api/v1/ prefix -->
- Deprecation policy: <!-- N months notice / link to policy doc -->

---

## Rate Limiting

| Scope | Limit | Window | Response |
|---|---|---|---|
| Per client | <!-- 100 req --> | <!-- per minute --> | `429 Too Many Requests` |

---

## Common Error Responses

| Status | Meaning | When |
|---|---|---|
| `400` | Bad Request | Validation failure |
| `401` | Unauthorized | Missing / invalid token |
| `403` | Forbidden | Insufficient permissions |
| `404` | Not Found | Resource does not exist |
| `409` | Conflict | Duplicate / state conflict |
| `500` | Internal Server Error | Unhandled exception |
| `503` | Service Unavailable | Dep service down / circuit open |

#!/usr/bin/env bash
# detect-workflows.sh
# Scans the repository for workflow entry points.
# Outputs discovered entry points grouped by type.
# Usage: bash .agents/skills/kb-skill/scripts/detect-workflows.sh [repo-root]

set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT"

echo "=== WORKFLOW ENTRY POINT SCAN ==="
echo "Scanning: $REPO_ROOT"
echo ""

# ─── REST Controllers ────────────────────────────────────────────────────────
echo "--- REST CONTROLLERS ---"

# Java / Kotlin Spring
if find . -name "*.java" -o -name "*.kt" | head -1 | grep -q .; then
  echo "[Spring Boot]"
  grep -rn --include="*.java" --include="*.kt" \
    -E "@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)" \
    --include="*Controller*" . 2>/dev/null \
    | awk -F: '{printf "  REST  %-60s → %s:%s\n", $3, $1, $2}' \
    | head -40 || true
fi

# Go (Gin / Chi / Echo / Gorilla)
if find . -name "*.go" | head -1 | grep -q .; then
  echo "[Go]"
  grep -rn --include="*.go" \
    -E '\.(GET|POST|PUT|DELETE|PATCH|Handle)\(' \
    . 2>/dev/null \
    | grep -v "_test.go" \
    | awk -F: '{printf "  REST  %-60s → %s:%s\n", $3, $1, $2}' \
    | head -40 || true
fi

# Node.js / TypeScript (Express / Fastify / NestJS)
if find . -name "*.ts" -o -name "*.js" | grep -v node_modules | head -1 | grep -q .; then
  echo "[Node/TypeScript]"
  grep -rn --include="*.ts" --include="*.js" \
    -E "(router|app)\.(get|post|put|delete|patch)\(|@(Get|Post|Put|Delete|Patch)\(" \
    --exclude-dir=node_modules . 2>/dev/null \
    | awk -F: '{printf "  REST  %-60s → %s:%s\n", $3, $1, $2}' \
    | head -40 || true
fi

# Python (FastAPI / Flask / Django)
if find . -name "*.py" | head -1 | grep -q .; then
  echo "[Python]"
  grep -rn --include="*.py" \
    -E "@(app|router)\.(get|post|put|delete|patch)|@api_view|path\(|url\(" \
    . 2>/dev/null \
    | awk -F: '{printf "  REST  %-60s → %s:%s\n", $3, $1, $2}' \
    | head -40 || true
fi

echo ""

# ─── Kafka Consumers ─────────────────────────────────────────────────────────
echo "--- KAFKA CONSUMERS ---"

grep -rn \
  --include="*.java" --include="*.kt" \
  --include="*.go" \
  --include="*.py" \
  --include="*.ts" --include="*.js" \
  -E "@KafkaListener|consumer\.subscribe\(|kafka\.NewConsumer|KafkaConsumer\(|@MessageMapping" \
  --exclude-dir=node_modules . 2>/dev/null \
  | awk -F: '{printf "  KAFKA %-60s → %s:%s\n", $3, $1, $2}' \
  | head -30 || true

echo ""

# ─── Scheduled / Cron Jobs ───────────────────────────────────────────────────
echo "--- SCHEDULED JOBS ---"

grep -rn \
  --include="*.java" --include="*.kt" \
  --include="*.go" \
  --include="*.py" \
  --include="*.ts" --include="*.js" \
  -E "@Scheduled|cron\.AddFunc|@Cron|schedule\.|celery\.task|apscheduler" \
  --exclude-dir=node_modules . 2>/dev/null \
  | awk -F: '{printf "  CRON  %-60s → %s:%s\n", $3, $1, $2}' \
  | head -20 || true

echo ""

# ─── CLI Commands ─────────────────────────────────────────────────────────────
echo "--- CLI COMMANDS ---"

grep -rn \
  --include="*.java" --include="*.kt" \
  --include="*.go" \
  --include="*.py" \
  --include="*.ts" --include="*.js" \
  -E "@Command|cobra\.Command|click\.command|commander\.command|@CliCommand|addCommand" \
  --exclude-dir=node_modules . 2>/dev/null \
  | awk -F: '{printf "  CLI   %-60s → %s:%s\n", $3, $1, $2}' \
  | head -20 || true

echo ""

# ─── gRPC Handlers ───────────────────────────────────────────────────────────
echo "--- GRPC HANDLERS ---"

grep -rn \
  --include="*.java" --include="*.kt" \
  --include="*.go" \
  --include="*.py" \
  -E "grpc\.RegisterService|RegisterServer|implements.*ServiceGrpc|ServiceBase\b" \
  . 2>/dev/null \
  | awk -F: '{printf "  GRPC  %-60s → %s:%s\n", $3, $1, $2}' \
  | head -20 || true

echo ""
echo "=== SCAN COMPLETE ==="
echo "Review the above and confirm which are distinct workflows."

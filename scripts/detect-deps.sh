#!/usr/bin/env bash
# detect-deps.sh
# Scans package manager files and import statements to discover
# likely inter-service dependencies.
# Usage: bash .agents/skills/kb-skill/scripts/detect-deps.sh [repo-root]

set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT"

echo "=== DEPENDENCY SCAN ==="
echo "Scanning: $REPO_ROOT"
echo ""

# ─── Maven (pom.xml) ─────────────────────────────────────────────────────────
if [ -f "pom.xml" ]; then
  echo "--- pom.xml (Maven) ---"
  grep -E "<artifactId>" pom.xml \
    | grep -v "^[[:space:]]*<!--" \
    | sed 's/.*<artifactId>\(.*\)<\/artifactId>.*/  \1/' \
    | grep -v "^  maven\|^  spring\|^  junit\|^  slf4j\|^  logback\|^  jackson" \
    | sort -u \
    | head -40 || true
  echo ""
fi

# ─── Gradle (build.gradle / build.gradle.kts) ────────────────────────────────
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  echo "--- build.gradle (Gradle) ---"
  grep -E "implementation|api\(" build.gradle build.gradle.kts 2>/dev/null \
    | grep -oE '"[^"]+:[^"]+:[^"]+"' \
    | awk -F: '{print "  " $2}' \
    | grep -v "spring\|junit\|slf4j\|logback\|jackson\|kotlin" \
    | sort -u \
    | head -40 || true
  echo ""
fi

# ─── Go modules (go.mod) ─────────────────────────────────────────────────────
if [ -f "go.mod" ]; then
  echo "--- go.mod (Go Modules) ---"
  awk '/^require/,/^\)/' go.mod \
    | grep -v "require\|^)" \
    | awk '{print "  " $1}' \
    | grep -v "golang.org\|google.golang\|github.com/go-\|github.com/pkg\|github.com/spf13" \
    | sort -u \
    | head -40 || true
  echo ""
fi

# ─── Node.js (package.json) ──────────────────────────────────────────────────
if [ -f "package.json" ]; then
  echo "--- package.json (npm/yarn) ---"
  grep -E '"[^"]+": "[^"]+"' package.json \
    | grep -v "eslint\|prettier\|jest\|typescript\|webpack\|babel\|@types\|lint\|test" \
    | awk -F'"' '{print "  " $2}' \
    | grep -v "^  $\|^  scripts\|^  version\|^  name" \
    | sort -u \
    | head -40 || true
  echo ""
fi

# ─── Python (requirements.txt / Pipfile) ─────────────────────────────────────
if [ -f "requirements.txt" ]; then
  echo "--- requirements.txt (Python) ---"
  grep -v "^#\|^-r\|^--" requirements.txt \
    | sed 's/[>=<].*//' \
    | awk '{print "  " $1}' \
    | grep -v "django\|flask\|fastapi\|pydantic\|sqlalchemy\|pytest\|black\|flake8" \
    | sort -u \
    | head -40 || true
  echo ""
fi

# ─── Cross-service client imports ────────────────────────────────────────────
echo "--- CROSS-SERVICE CLIENT IMPORTS ---"
echo "(Looking for *Client, *Stub, *Service imports that suggest inter-service calls)"

grep -rn \
  --include="*.java" --include="*.kt" \
  --include="*.go" \
  --include="*.py" \
  --include="*.ts" --include="*.js" \
  -E "import.*Client|import.*Stub|FeignClient|@LoadBalanced|RestTemplate|WebClient|grpc\.Dial" \
  --exclude-dir=node_modules \
  --exclude-dir=".kb" \
  . 2>/dev/null \
  | grep -v "test\|Test\|mock\|Mock\|spec\|Spec" \
  | awk -F: '{printf "  %-80s → %s:%s\n", $3, $1, $2}' \
  | sort -u \
  | head -30 || true

echo ""
echo "=== SCAN COMPLETE ==="
echo "Review and select which dependencies need a cross-repo KB entry."
echo "For each selected dep, provide its SSH clone URL."

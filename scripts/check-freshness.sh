#!/usr/bin/env bash
# check-freshness.sh
# Checks staleness of all deps in deps.config.yaml.
# Outputs a status line per dep: FRESH | STALE (reason) | SKIP (manual) | ERROR
# Usage: bash .agents/skills/kb-skill/scripts/check-freshness.sh [kb-root]

set -euo pipefail

KB_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.kb}"
DEPS_CONFIG="$KB_ROOT/deps/deps.config.yaml"

if [ ! -f "$DEPS_CONFIG" ]; then
  echo "ERROR: deps.config.yaml not found at $DEPS_CONFIG"
  echo "Run /kb setup first."
  exit 1
fi

echo "=== DEP KB FRESHNESS CHECK ==="
echo "Config: $DEPS_CONFIG"
echo "Time:   $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Read global refresh_strategy (default: ttl_and_hash)
GLOBAL_STRATEGY=$(grep "refresh_strategy:" "$DEPS_CONFIG" | head -1 | awk '{print $2}' | tr -d '"')
GLOBAL_STRATEGY="${GLOBAL_STRATEGY:-ttl_and_hash}"

# Read global ttl_days default
GLOBAL_TTL=$(grep "ttl_days:" "$DEPS_CONFIG" | head -1 | awk '{print $2}')
GLOBAL_TTL="${GLOBAL_TTL:-7}"

# Parse deps — simple line-based parser (works with the standard deps.config.yaml format)
# More robust parsing would use yq; this covers the standard template format.

CURRENT_NAME=""
CURRENT_URL=""
CURRENT_BRANCH="master"
CURRENT_TTL="$GLOBAL_TTL"
CURRENT_STRATEGY="$GLOBAL_STRATEGY"
CURRENT_FORCE="false"
CURRENT_KB_PATH=""

process_dep() {
  local name="$1"
  local url="$2"
  local branch="$3"
  local ttl="$4"
  local strategy="$5"
  local force="$6"
  local kb_path="$7"

  local meta_file="$KB_ROOT/deps/$name/META.md"
  local status=""
  local reason=""

  # Manual strategy — always skip
  if [ "$strategy" = "manual" ]; then
    printf "  ⏭️  %-30s SKIP    (refresh_strategy: manual)\n" "$name"
    return
  fi

  # Force refresh
  if [ "$force" = "true" ]; then
    printf "  ⚠️  %-30s STALE   (force_refresh=true)\n" "$name"
    return
  fi

  # META.md missing — first time
  if [ ! -f "$meta_file" ]; then
    printf "  ⚠️  %-30s STALE   (META.md not found — first time extraction needed)\n" "$name"
    return
  fi

  # TTL check
  if echo "$strategy" | grep -q "ttl"; then
    local last_fetched
    last_fetched=$(grep "Last Fetched" "$meta_file" | awk -F'|' '{print $3}' | tr -d ' ')

    if [ -n "$last_fetched" ] && [ "$last_fetched" != "null" ]; then
      # Compute age in days (macOS and Linux compatible)
      local fetch_epoch
      if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        fetch_epoch=$(date -d "$last_fetched" +%s 2>/dev/null || echo 0)
      else
        # BSD date (macOS)
        fetch_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_fetched" +%s 2>/dev/null || echo 0)
      fi

      local now_epoch
      now_epoch=$(date +%s)
      local age_days=$(( (now_epoch - fetch_epoch) / 86400 ))

      if [ "$age_days" -gt "$ttl" ]; then
        printf "  ⚠️  %-30s STALE   (TTL: %s days old, limit=%s days)\n" "$name" "$age_days" "$ttl"
        return
      fi
    else
      printf "  ⚠️  %-30s STALE   (last_fetched is null in META.md)\n" "$name"
      return
    fi
  fi

  # Hash drift check (uses git ls-remote — no clone needed)
  if echo "$strategy" | grep -q "hash"; then
    if [ -n "$url" ] && [ "$url" != "null" ]; then
      local remote_hash
      remote_hash=$(git ls-remote "$url" "refs/heads/$branch" 2>/dev/null | cut -f1 | head -1)

      if [ -n "$remote_hash" ]; then
        local local_hash
        local_hash=$(grep "HEAD Commit Hash" "$meta_file" | awk '{print $NF}' | tr -d '`' | head -1)

        if [ "$remote_hash" != "$local_hash" ]; then
          printf "  ⚠️  %-30s STALE   (hash drift: local=%s remote=%s)\n" \
            "$name" "${local_hash:0:8}" "${remote_hash:0:8}"
          return
        fi
      else
        printf "  ⚠️  %-30s WARN    (could not reach remote for hash check — SSH agent active?)\n" "$name"
        return
      fi
    fi
  fi

  printf "  ✅  %-30s FRESH\n" "$name"
}

# Simple YAML line parser for deps.config.yaml
while IFS= read -r line; do
  # Detect new dep entry
  if echo "$line" | grep -qE "^  - name:"; then
    # Process previous dep if we have one
    if [ -n "$CURRENT_NAME" ]; then
      process_dep "$CURRENT_NAME" "$CURRENT_URL" "$CURRENT_BRANCH" \
        "$CURRENT_TTL" "$CURRENT_STRATEGY" "$CURRENT_FORCE" "$CURRENT_KB_PATH"
    fi
    CURRENT_NAME=$(echo "$line" | awk -F'"' '{print $2}')
    CURRENT_URL=""
    CURRENT_BRANCH="master"
    CURRENT_TTL="$GLOBAL_TTL"
    CURRENT_STRATEGY="$GLOBAL_STRATEGY"
    CURRENT_FORCE="false"
    CURRENT_KB_PATH=""
  fi

  if echo "$line" | grep -qE "^    gitlab_url:"; then
    CURRENT_URL=$(echo "$line" | awk -F'"' '{print $2}')
  fi
  if echo "$line" | grep -qE "^    branch:"; then
    CURRENT_BRANCH=$(echo "$line" | awk -F'"' '{print $2}')
  fi
  if echo "$line" | grep -qE "^    ttl_days:"; then
    CURRENT_TTL=$(echo "$line" | awk '{print $2}')
  fi
  if echo "$line" | grep -qE "^    refresh_strategy:"; then
    CURRENT_STRATEGY=$(echo "$line" | awk -F'"' '{print $2}')
  fi
  if echo "$line" | grep -qE "^    force_refresh:"; then
    CURRENT_FORCE=$(echo "$line" | awk '{print $2}')
  fi
  if echo "$line" | grep -qE "^    kb_path:"; then
    CURRENT_KB_PATH=$(echo "$line" | awk -F'"' '{print $2}')
  fi
done < "$DEPS_CONFIG"

# Process the last dep
if [ -n "$CURRENT_NAME" ]; then
  process_dep "$CURRENT_NAME" "$CURRENT_URL" "$CURRENT_BRANCH" \
    "$CURRENT_TTL" "$CURRENT_STRATEGY" "$CURRENT_FORCE" "$CURRENT_KB_PATH"
fi

echo ""
echo "=== CHECK COMPLETE ==="

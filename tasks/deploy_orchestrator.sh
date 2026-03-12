#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
LOG="$ROOT/logs/deploy_orchestrator.log"
COMPOSE_DIR="$ROOT/compose"
OVR="$COMPOSE_DIR/docker-compose.override.yml"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR"

echo "$(date -u +'%FT%TZ') [orchestrator] begin" >> "$LOG"

docker compose -f "$COMPOSE_DIR/docker-compose.yml" ps >> "$LOG" 2>&1 || true

cat >"$OVR" <<'YAML'
version: "3.8"
services:

orchestrator (placeholder; will be enabled next round)

orchestrator:

image: alpine:3.19

command: ["sh","-c","sleep infinity"]

restart: unless-stopped

environment:

- REDIS_URL=redis://redis:6379

- PG_HOST=postgres

- PG_USER=${PG_USER}

- PG_PASSWORD=${PG_PASS}

- PG_DATABASE=${PG_DB}

depends_on:

- redis

- postgres

- qdrant

YAML

docker compose -f "$COMPOSE_DIR/docker-compose.yml" -f "$OVR" config >/dev/null

echo "$(date -u +'%FT%TZ') [orchestrator] OK (override ready, no new services started)" >> "$LOG"

tasks/deploy_agents.sh
#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
LOG="$ROOT/logs/deploy_agents.log"
COMPOSE_DIR="$ROOT/compose"
OVR="$COMPOSE_DIR/docker-compose.override.yml"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR"

echo "$(date -u +'%FT%TZ') [agents] begin" >> "$LOG"

docker compose -f "$COMPOSE_DIR/docker-compose.yml" -f "$OVR" config >/dev/null

echo "$(date -u +'%FT%TZ') [agents] OK (validated, no new services started)" >> "$LOG"

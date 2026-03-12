#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
LOG="$ROOT/logs/deploy_agents.log"
COMPOSE_DIR="$ROOT/compose"
BASE="$COMPOSE_DIR/docker-compose.yml"
OVR="$COMPOSE_DIR/docker-compose.override.yml"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR"

echo "$(date -u +'%FT%TZ') [agents] begin" >> "$LOG"

cat >>"$OVR" <<'YAML'

planner:
image: alpine:3.19
command: ["sh","-c","echo 'planner idle' && while :; do sleep 60; done"]
restart: unless-stopped
environment:

- REDIS_URL=redis://redis:6379
- QDRANT_URL=http://qdrant:6333
depends_on:
- redis
- qdrant

executor:
image: alpine:3.19
command: ["sh","-c","echo 'executor idle' && while :; do sleep 60; done"]
restart: unless-stopped
environment:

- REDIS_URL=redis://redis:6379
- PG_HOST=postgres
- PGUSER=${PG_USER}
- PGPASSWORD=${PG_PASS}
- PGDATABASE=${PG_DB}
depends_on:
- redis
- postgres

auditor:
image: alpine:3.19
command: ["sh","-c","echo 'auditor idle' && while :; do sleep 60; done"]
restart: unless-stopped
environment:

- REDIS_URL=redis://redis:6379
depends_on:
- redis

memory:
image: alpine:3.19
command: ["sh","-c","echo 'memory idle' && while :; do sleep 60; done"]
restart: unless-stopped
environment:

- QDRANT_URL=http://qdrant:6333
- PG_HOST=postgres
- PGUSER=${PG_USER}
- PGPASSWORD=${PG_PASS}
- PGDATABASE=${PG_DB}
depends_on:
- qdrant
- postgres
YAML

docker compose -f "$BASE" -f "$OVR" config >/dev/null
docker compose -f "$BASE" -f "$OVR" up -d planner executor auditor memory >> "$LOG" 2>&1
docker compose -f "$BASE" -f "$OVR" ps planner executor auditor memory >> "$LOG" 2>&1 || true

echo "$(date -u +'%FT%TZ') [agents] OK (services up)" >> "$LOG"

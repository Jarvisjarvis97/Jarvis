#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
COMPOSE_DIR="$ROOT/compose"
ENV_DIR="$ROOT/env"
LOG="$ROOT/logs/deploy_base.log"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR" "$ENV_DIR"

1) Check docker & compose

if ! command -v docker >/dev/null 2>&1; then
echo "docker not found" >>"$LOG"; exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
echo "docker compose plugin not found" >>"$LOG"; exit 1
fi

2) Write compose if missing

if [ ! -f "$COMPOSE_DIR/docker-compose.yml" ]; then
cat >"$COMPOSE_DIR/docker-compose.yml" <<'YAML'
version: "3.9"
services:
redis:
image: redis:7-alpine
restart: always
command: ["redis-server","--appendonly","yes"]
volumes: ["redis-data:/data"]

postgres:
image: postgres:16-alpine
restart: always
environment:
POSTGRES_USER: ${PG_USER}
POSTGRES_PASSWORD: ${PG_PASS}
POSTGRES_DB: ${PG_DB}
volumes: ["pg-data:/var/lib/postgresql/data"]

qdrant:
image: qdrant/qdrant:latest
restart: always
volumes: ["qdrant-data:/qdrant/storage"]

volumes:
redis-data:
pg-data:
qdrant-data:
YAML
fi

3) Write .env if missing

if [ ! -f "$ENV_DIR/.env" ]; then
cat >"$ENV_DIR/.env" <<'ENV'
PG_USER=jarvis
PG_PASS=change-me
PG_DB=jarvis

OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GOOGLE_API_KEY=
XAI_API_KEY=

OAI_TARGET_PCT=70
ANTH_TARGET_PCT=30
ENV
fi

4) Bring up base services

cd "$ROOT"
docker compose -f "$COMPOSE_DIR/docker-compose.yml" --env-file "$ENV_DIR/.env" up -d >>"$LOG" 2>&1 || { echo "compose up failed" >>"$LOG"; exit 1; }

5) Print status

docker compose -f "$COMPOSE_DIR/docker-compose.yml" ps >>"$LOG" 2>&1

echo "$(date -u +'%FT%TZ') deploy_base OK" >>"$LOG"

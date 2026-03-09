cat >/opt/jarvis/tasks/pending/deploy_base.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
COMPOSE_DIR="$ROOT/compose"
ENV_DIR="$ROOT/env"
LOG="$ROOT/logs/deploy_base.log"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR" "$ENV_DIR"

if ! command -v docker >/dev/null 2>&1; then
echo "docker not found" >>"$LOG"; exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
echo "docker compose plugin not found" >>"$LOG"; exit 1
fi

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

cd "$ROOT"
docker compose -f "$COMPOSE_DIR/docker-compose.yml" --env-file "$ENV_DIR/.env" up -d >>"$LOG" 2>&1  { echo "compose up failed" >>"$LOG"; exit 1; }
docker compose -f "$COMPOSE_DIR/docker-compose.yml" ps >>"$LOG" 2>&1
echo "$(date -u +'%FT%TZ') deploy_base OK" >>"$LOG"
EOF
chmod +x /opt/jarvis/tasks/pending/deploy_base.sh
sed -i 's/\r$//' /opt/jarvis/tasks/pending/deploy_base.sh
touch /opt/jarvis/tasks/approved/deploy_base.sh.approved
systemctl start jarvis-runner.service
tail -n 100 /opt/jarvis/logs/runner.log
tail -n 100 /opt/jarvis/logs/deploy_base.log
docker compose -f /opt/jarvis/compose/docker-compose.yml ps  echo "compose file not yet"

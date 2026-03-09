#!/usr/bin/env bash
set -euo pipefail

ROOT="/opt/jarvis"
COMPOSE_DIR="$ROOT/compose"
ENV_DIR="$ROOT/env"
LOG="$ROOT/logs/deploy_base.log"

mkdir -p "$ROOT/logs" "$COMPOSE_DIR" "$ENV_DIR"

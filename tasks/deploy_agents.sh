#!/usr/bin/env bash
set -euo pipefail
ROOT="/opt/jarvis"
mkdir -p "$ROOT/logs"
echo "agents OK" >> "$ROOT/logs/deploy_agents.log"

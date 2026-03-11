#!/usr/bin/env bash
set -euo pipefail
ROOT="/opt/jarvis"
mkdir -p "$ROOT/logs"
echo "orchestrator OK" >> "$ROOT/logs/deploy_orchestrator.log"

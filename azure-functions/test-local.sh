#!/usr/bin/env bash
# Runs hello, world, frontend, and loadgen locally via Azure Functions Core
# Tools, wired together the same way deploy.sh wires the real Function Apps -
# so you can validate the adapters end-to-end before spending anything on
# Azure. No cloud resources are created.
#
# Usage:
#   ./test-local.sh start    # build venvs (if needed) and start all four
#   ./test-local.sh status   # curl hello/world/frontend, tail loadgen's log
#   ./test-local.sh stop     # kill all four and clean up venvs/logs
#
# Prerequisites: same as deploy.sh (func Core Tools v4, Python 3.11 or 3.12 -
# NOT 3.13, the Functions Python worker hangs on init with it as of this
# writing).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN_DIR="/tmp/doodle-func-local"
mkdir -p "$RUN_DIR"

HELLO_PORT=7071
FRONTEND_PORT=7072
WORLD_PORT=7073
LOADGEN_PORT=7074

find_python() {
  for candidate in python3.11 python3.12; do
    if command -v "$candidate" >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done
  echo "ERROR: need python3.11 or python3.12 on PATH (3.13 does not work with the Functions Python worker yet)" >&2
  exit 1
}

PYTHON_BIN="$(find_python)"

setup_and_start() {
  local repo_dir=$1
  local port=$2
  local settings_json=$3
  local dir="$REPO_ROOT/$repo_dir/azure-functions"

  echo "== $repo_dir (port $port) =="
  (
    cd "$dir"
    if [ ! -d .venv ]; then
      "$PYTHON_BIN" -m venv .venv
    fi
    # shellcheck disable=SC1091
    source .venv/bin/activate
    pip install -q -r requirements.txt
    echo "$settings_json" > local.settings.json
    nohup func start --port "$port" > "$RUN_DIR/$repo_dir.log" 2>&1 &
    echo $! > "$RUN_DIR/$repo_dir.pid"
    deactivate
  )
}

cmd_start() {
  setup_and_start "gitops-doodle-hello" "$HELLO_PORT" '{
    "IsEncrypted": false,
    "Values": {
      "AzureWebJobsStorage": "",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "ERROR_THRESH": "10",
      "WEATHER_THRESH": "25",
      "SHARD": "local-fn-test"
    }
  }'

  setup_and_start "gitops-doodle-world" "$WORLD_PORT" '{
    "IsEncrypted": false,
    "Values": {
      "AzureWebJobsStorage": "",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "SHARD": "local-fn-test"
    }
  }'

  setup_and_start "gitops-doodle-frontend" "$FRONTEND_PORT" "{
    \"IsEncrypted\": false,
    \"Values\": {
      \"AzureWebJobsStorage\": \"\",
      \"FUNCTIONS_WORKER_RUNTIME\": \"python\",
      \"SHARD\": \"local-fn-test\",
      \"RUBY_WORLD\": \"0\",
      \"HELLO_URL\": \"http://localhost:${HELLO_PORT}\",
      \"WORLD_URL\": \"http://localhost:${WORLD_PORT}\"
    }
  }"

  setup_and_start "gitops-doodle-loadgen" "$LOADGEN_PORT" "{
    \"IsEncrypted\": false,
    \"Values\": {
      \"AzureWebJobsStorage\": \"\",
      \"FUNCTIONS_WORKER_RUNTIME\": \"python\",
      \"F_HOST\": \"localhost\",
      \"F_PORT\": \"${FRONTEND_PORT}\",
      \"LOADGEN_SCHEDULE\": \"*/5 * * * * *\"
    }
  }"

  echo ""
  echo "Starting up, giving the workers ~12s to initialize..."
  sleep 12
  cmd_status
}

cmd_status() {
  echo "== hello (http://localhost:$HELLO_PORT/get_uuid) =="
  curl -s -m 5 -w "\nHTTP_STATUS:%{http_code}\n" "http://localhost:$HELLO_PORT/get_uuid" || echo "(not responding)"
  echo ""
  echo "== world (http://localhost:$WORLD_PORT/) =="
  curl -s -m 5 -w "\nHTTP_STATUS:%{http_code}\n" "http://localhost:$WORLD_PORT/" || echo "(not responding)"
  echo ""
  echo "== frontend (http://localhost:$FRONTEND_PORT/) =="
  curl -s -m 5 -w "\nHTTP_STATUS:%{http_code}\n" "http://localhost:$FRONTEND_PORT/" || echo "(not responding)"
  echo ""
  echo "== loadgen (last 5 log lines - should show periodic requests to frontend) =="
  tail -n 5 "$RUN_DIR/gitops-doodle-loadgen.log" 2>/dev/null || echo "(no log yet)"
}

kill_port() {
  local port=$1
  local pids
  pids="$(lsof -ti ":$port" 2>/dev/null || true)"
  [ -z "$pids" ] && return 0

  # func start doesn't always die cleanly on SIGTERM (it can get reparented
  # to launchd instead of exiting) - try graceful first, then force it.
  echo "$pids" | xargs kill 2>/dev/null || true
  sleep 2
  pids="$(lsof -ti ":$port" 2>/dev/null || true)"
  if [ -n "$pids" ]; then
    echo "  port $port still held, force-killing: $pids"
    echo "$pids" | xargs kill -9 2>/dev/null || true
  fi
}

cmd_stop() {
  for port in "$HELLO_PORT" "$FRONTEND_PORT" "$WORLD_PORT" "$LOADGEN_PORT"; do
    kill_port "$port"
  done

  for repo_dir in gitops-doodle-hello gitops-doodle-world gitops-doodle-frontend gitops-doodle-loadgen; do
    rm -rf "$REPO_ROOT/$repo_dir/azure-functions/.venv"
    rm -f "$REPO_ROOT/$repo_dir/azure-functions/local.settings.json"
  done
  rm -rf "$RUN_DIR"

  local still_up
  still_up="$(lsof -i ":$HELLO_PORT,$FRONTEND_PORT,$WORLD_PORT,$LOADGEN_PORT" 2>/dev/null || true)"
  if [ -n "$still_up" ]; then
    echo "WARNING: something is still listening on one of the test ports:"
    echo "$still_up"
  else
    echo "Stopped and cleaned up - ports $HELLO_PORT/$FRONTEND_PORT/$WORLD_PORT/$LOADGEN_PORT confirmed free."
  fi
}

case "${1:-start}" in
  start) cmd_start ;;
  status) cmd_status ;;
  stop) cmd_stop ;;
  *) echo "Usage: $0 [start|status|stop]" >&2; exit 1 ;;
esac

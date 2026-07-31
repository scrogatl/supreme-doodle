#!/usr/bin/env bash
# Deploys loadgen, frontend, hello, and world as Azure Function Apps, with
# hello/world/frontend instrumented via the New Relic Python agent.
#
# Prerequisites:
#   - az CLI installed and logged in (`az login`)
#   - Azure Functions Core Tools installed (`func`, v4)
#   - python3.11 or python3.12 on PATH by that exact name (used to build each
#     app's dependencies) - matches PYTHON_VERSION below; newer Pythons
#     (3.13 as of this writing) aren't yet supported by the Functions
#     Python worker.
#   - gitops-doodle-hello, gitops-doodle-frontend, and gitops-doodle-world
#     cloned as siblings of this repo, each on their `azure-functions-newrelic`
#     branch (that's where the New Relic instrumentation actually lives -
#     their `main` branches have the adapter but no New Relic code).
#   - gitops-doodle-loadgen cloned as a sibling too, on `main` (loadgen is
#     deployed but deliberately NOT instrumented with New Relic).
#
# world-ruby and weather are NOT included: Azure Functions has no supported
# Ruby runtime, and weather's .NET isolated-worker migration is a separate,
# more involved effort.
#
# New Relic reporting is optional: set NEW_RELIC_LICENSE_KEY in your
# environment before running this script to actually report data. Without
# it, the agent initializes but simply doesn't report anything - it will
# not break the deployment.
set -euo pipefail

NEW_RELIC_LICENSE_KEY="${NEW_RELIC_LICENSE_KEY:-}"
if [ -z "$NEW_RELIC_LICENSE_KEY" ]; then
  echo "NOTE: NEW_RELIC_LICENSE_KEY not set - hello/world/frontend will run with the New Relic agent enabled but not reporting anything."
fi

# ---- Configuration - edit these for your environment ----
RESOURCE_GROUP="${RESOURCE_GROUP:-supreme-doodle-func}"
LOCATION="${LOCATION:-eastus2}"
# Must be globally unique, lowercase + numbers only, 3-24 chars.
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-doodlefuncsa$RANDOM}"
# Function App names must be globally unique across all of Azure (they become
# <name>.azurewebsites.net) - the default embeds $RANDOM to help with that.
PREFIX="${PREFIX:-doodle-$RANDOM}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"

HELLO_APP="${PREFIX}-hello"
WORLD_APP="${PREFIX}-world"
FRONTEND_APP="${PREFIX}-frontend"
LOADGEN_APP="${PREFIX}-loadgen"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

find_python() {
  for candidate in python3.11 python3.12; do
    if command -v "$candidate" >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done
  echo "ERROR: need python3.11 or python3.12 on PATH to build the same version the Function Apps run" >&2
  exit 1
}

PYTHON_BIN="$(find_python)"

check_branch() {
  local repo_dir=$1
  local expected_branch=$2
  local actual_branch
  actual_branch="$(git -C "$REPO_ROOT/$repo_dir" branch --show-current)"
  if [ "$actual_branch" != "$expected_branch" ]; then
    echo "ERROR: $repo_dir is on branch '$actual_branch', expected '$expected_branch'." >&2
    echo "       git -C $REPO_ROOT/$repo_dir checkout $expected_branch" >&2
    exit 1
  fi
}

check_branch "gitops-doodle-hello" "azure-functions-newrelic"
check_branch "gitops-doodle-world" "azure-functions-newrelic"
check_branch "gitops-doodle-frontend" "azure-functions-newrelic"
check_branch "gitops-doodle-loadgen" "main"

echo "== Resource group: $RESOURCE_GROUP ($LOCATION) =="
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

echo "== Storage account: $STORAGE_ACCOUNT =="
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --output none

create_function_app() {
  local app_name=$1
  echo "== Creating Function App: $app_name =="
  az functionapp create \
    --resource-group "$RESOURCE_GROUP" \
    --consumption-plan-location "$LOCATION" \
    --runtime python \
    --runtime-version "$PYTHON_VERSION" \
    --functions-version 4 \
    --os-type linux \
    --name "$app_name" \
    --storage-account "$STORAGE_ACCOUNT" \
    --output none
}

create_function_app "$HELLO_APP"
create_function_app "$WORLD_APP"
create_function_app "$FRONTEND_APP"
create_function_app "$LOADGEN_APP"

publish_app() {
  local repo_dir=$1
  local app_name=$2
  local src_app_py=$3  # path to the real app.py, relative to $repo_dir
  echo "== Publishing $app_name from $repo_dir/azure-functions =="
  (
    cd "$REPO_ROOT/$repo_dir/azure-functions"
    # Azure's remote build only packages this directory, not sibling repo
    # folders - copy the real source in so the deployed artifact is
    # self-contained. hello/src/app.py etc. stays the source of truth;
    # this copy is a build artifact (gitignored), not committed.
    cp "../$src_app_py" app.py
    "$PYTHON_BIN" -m venv .venv
    # shellcheck disable=SC1091
    source .venv/bin/activate
    pip install -q -r requirements.txt
    func azure functionapp publish "$app_name" --python
    deactivate
    rm -f app.py
  )
}

publish_app "gitops-doodle-hello" "$HELLO_APP" "hello/src/app.py"
publish_app "gitops-doodle-world" "$WORLD_APP" "world/src/app.py"
publish_app "gitops-doodle-frontend" "$FRONTEND_APP" "frontend/src/app.py"
publish_app "gitops-doodle-loadgen" "$LOADGEN_APP" "loadgen/app.py"

echo "== Wiring cross-service app settings =="

az functionapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$HELLO_APP" --settings \
  ERROR_THRESH=10 \
  WEATHER_THRESH=25 \
  SHARD=azure-fn \
  "NEW_RELIC_APP_NAME=${HELLO_APP}" \
  "NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}" \
  --output none

az functionapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$WORLD_APP" --settings \
  SHARD=azure-fn \
  "NEW_RELIC_APP_NAME=${WORLD_APP}" \
  "NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}" \
  --output none

az functionapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$FRONTEND_APP" --settings \
  "HELLO_URL=https://${HELLO_APP}.azurewebsites.net" \
  "WORLD_URL=https://${WORLD_APP}.azurewebsites.net" \
  RUBY_WORLD=0 \
  SHARD=azure-fn \
  "NEW_RELIC_APP_NAME=${FRONTEND_APP}" \
  "NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY}" \
  --output none

az functionapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$LOADGEN_APP" --settings \
  "F_HOST=${FRONTEND_APP}" \
  CONTAINER_APP_ENV_DNS_SUFFIX=azurewebsites.net \
  --output none

echo ""
echo "== Done =="
echo "frontend: https://${FRONTEND_APP}.azurewebsites.net/"
echo "hello:    https://${HELLO_APP}.azurewebsites.net/get_uuid"
echo "world:    https://${WORLD_APP}.azurewebsites.net/"
echo "loadgen:  runs on a timer, no public endpoint - check its Log Stream in the portal"

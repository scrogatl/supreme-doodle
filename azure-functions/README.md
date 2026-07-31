# Deploying to Azure Functions

Deploys `loadgen`, `frontend`, `hello`, and `world` as four separate Azure
Function Apps. Each service's `azure-functions/` directory (in its own repo)
wraps the existing Flask app (or, for loadgen, its request-sending function)
with a thin Azure Functions adapter - no business logic is duplicated, and
the Docker/Kubernetes deployment paths for these repos are unaffected.

**Not included:** `world-ruby` (Azure Functions has no supported Ruby
runtime) and `weather` (its .NET migration to the isolated-worker model is a
separate effort). `hello`'s calls to weather will just fail gracefully, the
same as when weather is unreachable in any other deployment.

**This branch (`azure-functions-newrelic`) instruments `hello`, `world`, and
`frontend` with the New Relic Python agent.** `loadgen` is deliberately left
uninstrumented. If you want the Azure Functions adapters with no New Relic
code at all, use `main` instead (in both this repo and the three service
repos) - `deploy.sh`/`test-local.sh` here check each sibling repo is on the
branch they expect and fail fast with the fix if not.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), logged in (`az login`)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local) (`func`)
- Python 3.11 available locally (`python3.11` or a `python3` that resolves to
  it) - used to build each app's dependencies before publishing. Newer
  Pythons (3.13 as of this writing) aren't yet supported by the Functions
  Python worker and will hang on startup with a worker-initialization timeout.
- `gitops-doodle-hello`, `gitops-doodle-frontend`, and `gitops-doodle-world`
  cloned as siblings of this repo, each checked out on `azure-functions-newrelic`
  - that's where the New Relic instrumentation actually lives, not `main`.
- `gitops-doodle-loadgen` cloned as a sibling too, checked out on `main`
  (same layout `docker-compose.yml` expects) - it's deployed but not
  instrumented.
- Optionally, `NEW_RELIC_LICENSE_KEY` exported in your shell before running
  either script. Without it, the agent still initializes on hello/world/
  frontend but simply doesn't report any data - it won't break the deploy.

### On Ubuntu / other Linux

Everything here (`deploy.sh`, `test-local.sh`) is plain bash and portable,
but a few things aren't preinstalled on a typical Linux box the way they are
on macOS:

- `lsof` - `test-local.sh` uses it to find/kill processes by port. Minimal
  server/container images often don't have it: `sudo apt install lsof`.
- `python3.11` / `python3.12` by that exact binary name - Ubuntu's default
  `python3` varies by release (22.04 ships 3.10, 24.04 ships 3.12). If
  neither `python3.11` nor `python3.12` is on `PATH`, install one
  (`sudo apt install python3.11`, or via the deadsnakes PPA on older releases).
- `func` (Azure Functions Core Tools) installs differently than on macOS -
  use `npm install -g azure-functions-core-tools@4` or
  [Microsoft's apt feed](https://learn.microsoft.com/azure/azure-functions/functions-run-local),
  not Homebrew.

## Deploy

```
cd azure-functions
./deploy.sh
```

Override any of the defaults via environment variables:

```
RESOURCE_GROUP=my-rg LOCATION=westus2 PREFIX=my-doodle NEW_RELIC_LICENSE_KEY=... ./deploy.sh
```

This creates a resource group, a storage account, four Linux Python
Consumption-plan Function Apps, publishes each app's code, then wires the
cross-service app settings (`HELLO_URL`/`WORLD_URL` on frontend, `F_HOST` on
loadgen) using the actual deployed hostnames, plus `NEW_RELIC_APP_NAME` (set
to each Function App's own name) and `NEW_RELIC_LICENSE_KEY` on hello/world/
frontend.

## Verify

```
curl https://<prefix>-frontend.azurewebsites.net/
curl https://<prefix>-hello.azurewebsites.net/get_uuid
curl https://<prefix>-world.azurewebsites.net/
```

`frontend`'s response should show both a `hello status:` and `world status:`
line - `hello status: 500` some fraction of the time is expected, it's
`hello`'s own intentional `ERROR_THRESH` fault injection, not a deployment
problem.

`loadgen` has no HTTP endpoint (it's timer-triggered, firing every 5 seconds
by default). Check it's running via its Log Stream:

```
az functionapp log tail --resource-group <resource-group> --name <prefix>-loadgen
```

## Troubleshooting

- **404 on every route**: check `host.json` in that app's `azure-functions/`
  directory has `"extensions": {"http": {"routePrefix": ""}}`. Without it,
  Azure puts every route under `/api/...`, but the wrapped Flask app only
  knows its own routes (`/get_uuid`, not `/api/get_uuid`).
- **frontend can't reach hello/world**: confirm `HELLO_URL`/`WORLD_URL` app
  settings are full `https://...azurewebsites.net` URLs with no path or
  trailing slash, and that those two Function Apps are actually running
  (`az functionapp show --name <app> --query state`).
- **Worker fails to initialize / times out locally**: almost always a Python
  version mismatch. Rebuild the venv with Python 3.11 or 3.12, not 3.13.
- **"is on branch 'main', expected 'azure-functions-newrelic'"**: exactly
  what it says - check out the right branch in that sibling repo. Both
  scripts check this upfront rather than silently deploying/testing the
  wrong (non-instrumented) code.

## Cleanup

```
az group delete --name <resource-group> --yes --no-wait
```

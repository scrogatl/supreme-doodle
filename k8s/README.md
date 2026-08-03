# k8s

Plain Kubernetes manifests (`deployments/`, `services/`) plus config for the
New Relic OTel collector (`nr-k8s-otel-collector` chart) that instruments the
cluster hosting these services.

- `values.yaml` — the chart's own defaults, kept here unmodified for reference/diffing.
- `your-custom-values.yaml` — this cluster's actual values, applied via `helm install/upgrade -f your-custom-values.yaml ...`.
- `coredns-node-hosts.yaml` — CoreDNS fix for bare-metal/microk8s clusters where node hostnames don't resolve in-cluster (see the "Missing CPU/Memory..." section in the root [README](../README.md)).

## Custom OTLP pipelines in `your-custom-values.yaml`

The doodle services export their own traces/logs/metrics via OTLP directly to
`nrdot-collector:4317` (see root [CLAUDE.md](../CLAUDE.md)). The chart's default
config doesn't know what to do with that inbound OTLP traffic on its own, so
`deployment.configMap.extraConfig` extends the deployment collector with:

### `k8s_attributes/traces` processor

Enriches every span/metric/log with Kubernetes metadata (namespace, pod name,
node, container, image, etc.) by querying the K8s API via the collector's
service account (`auth_type: serviceAccount`). It's keyed off `k8s.pod.uid`,
associated either from the resource attribute set by the OTLP-emitting pod or
from the originating connection.

Despite the `/traces` suffix in its name, it's used in all three custom
pipelines below (traces, metrics, logs) — the name is a holdover from when it
was traces-only and hasn't been renamed.

### `debug` exporter

Dumps full payloads (`verbosity: detailed`) to the collector pod's stdout.
Wired into the `traces` and `metrics/otlp` pipelines (not `logs`). This is
deliberately noisy — useful for watching this demo's telemetry land in real
time via `kubectl logs`, not something you'd want in a production pipeline.

### The three pipelines

| Pipeline | Receivers | Processors | Exporters |
|---|---|---|---|
| `traces` | `[otlp]` | `[batch, k8s_attributes/traces]` | `[otlp_http/newrelic, debug]` |
| `metrics/otlp` | `[otlp]` | `[batch, k8s_attributes/traces]` | `[otlp_http/newrelic, debug]` |
| `logs` | `[otlp]` | `[batch, k8s_attributes/traces]` | `[otlp_http/newrelic]` |

`metrics/otlp` is named distinctly (not just `metrics`) so it runs alongside
the chart's own built-in `metrics` pipeline (fed by `hostmetrics`/`kubeletstats`/
`prometheus`) rather than replacing it — one pipeline carries cluster/node
infra metrics, the other carries the doodle services' own OTLP metrics.

Note: `k8s.cluster.name` does **not** need to be set manually in this
extraConfig — the chart already stamps it (and other standard attributes) via
its own built-in `resource/newrelic` processor, driven by the top-level
`cluster:` value in `your-custom-values.yaml`.

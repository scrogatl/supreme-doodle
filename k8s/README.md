# your-custom-values.yaml

This is New Relic's [`nr-k8s-otel-collector`](https://github.com/newrelic/helm-charts/tree/master/charts/nr-k8s-otel-collector)
Helm chart's stock `values.yaml`, customized for this cluster. Changes from
the chart default:

### 1. Cluster name and region set explicitly
```yaml
cluster: "mk8s-nrdot-06"
region: "us"
```
The stock file ships both blank. `cluster` is mandatory, and `region` is
required once you're using a custom secret for the license key (see below).

### 2. License key comes from a Secret, not plaintext
```yaml
customSecretName: "nr-license-key"
customSecretLicenseKey: "licenseKey"
```
The stock file has a plaintext `licenseKey: ""` field. Here the key is
pulled from a Kubernetes Secret instead, so it never lives in this file.
Create the secret with:
```
kubectl create secret generic nr-license-key --from-literal=licenseKey=<YOUR_INGEST_KEY>
```
**Note:** the literal key name after `--from-literal=` must match
`customSecretLicenseKey` above (`licenseKey`). The command in the root
README currently uses `license-key` (with a hyphen) — that won't match
this file's config and should be corrected if you're creating the secret
from that instructions.

### 3. Deployment collector `extraConfig`: added processors, exporter, and pipelines
The stock file's `deployment.configMap.extraConfig` is empty. This file adds:

- **`k8s_attributes/traces` processor** — extracts pod/container/deployment
  metadata (namespace, pod name/uid, node, container name/id/image) via the
  collector's service account, associating records by `k8s.pod.uid` first
  and falling back to connection info.
- **`resource/cluster` processor** — upserts `k8s.cluster.name` onto every
  record. This is required for New Relic to link the OTel-instrumented
  service entity to its Kubernetes container/pod entity — it looks
  redundant with `k8s_attributes/traces` but isn't; removing it breaks the
  service-to-container link (confirmed empirically — see commit history on
  this file for the revert of an attempt to drop it).
- **`debug` exporter** (`verbosity: detailed`) — logs a copy of pipeline
  output from the collector container, for troubleshooting.
- **Custom `traces` / `metrics/otlp` / `logs` pipelines** — each runs
  `batch` → `k8s_attributes/traces` → `resource/cluster`, exporting to
  `otlp_http/newrelic` (traces and metrics also fan out to `debug`).

### 4. `lowDataMode: true` set explicitly
The stock file ships this blank (the chart still defaults it to `true`);
this file pins it explicitly so it's not relying on an undocumented default.

# Environment baseline

This repository is tested against a personal K3s homelab. Private addresses, kubeconfig data, tokens, and credentials are intentionally excluded.

## Network disclosure policy

For portfolio documentation, the node network is represented as **`172.16.0.0/24`**. This is an anonymized documentation range, not the lab's real addressing scheme. Individual node addresses are never committed.

| Role | Hostname | Capacity | Kubernetes version |
| --- | --- | --- | --- |
| Control plane | `cp01` | 2 vCPU / 4 GB RAM | `v1.36.5+k3s1` |
| Worker | `wk01` | 2 vCPU / 4 GB RAM | `v1.36.5+k3s1` |
| Worker | `wk02` | 2 vCPU / 4 GB RAM | `v1.36.5+k3s1` |
| Worker | `wk03` | 2 vCPU / 4 GB RAM | `v1.36.5+k3s1` |

## Platform baseline

- CNI: Cilium, with Cilium Envoy running on all nodes.
- Storage: default `local-path` StorageClass (`WaitForFirstConsumer`, `Delete` reclaim policy) for simple local volumes; `nfs-csi` (`Immediate`, `Retain`, expansion enabled) is available for shared/persistent workloads. Its endpoint is intentionally not documented.
- Metrics: metrics-server is running and `kubectl top nodes` returns data.
- Ingress: no `IngressClass` is installed yet; ingress/TLS is intentionally covered by a later project.

## Baseline health snapshot

On 2026-10-21 all four nodes were `Ready`; cluster services (Cilium, CoreDNS, metrics-server, and local-path-provisioner) were healthy. Node usage was below 25% memory utilization at the time of measurement.

## Operational constraints

- Preserve at least 25% memory headroom per node.
- Every non-trivial workload declares CPU/memory requests and limits.
- Enable resource-heavy platforms only while demonstrating or validating them.
- Do not commit raw diagnostic output without redaction; do not disclose individual node or pod IP addresses.

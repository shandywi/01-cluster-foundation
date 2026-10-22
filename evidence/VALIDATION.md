# Project 01 validation evidence

Validation was performed on **2026-10-21** using context `cl1`. This file intentionally excludes kubeconfig data, individual internal IP addresses, and raw diagnostic output. The lab network is represented publicly as `172.16.0.0/24`.

## Baseline health

| Check | Result |
| --- | --- |
| Nodes | `cp01`, `wk01`, `wk02`, and `wk03` were `Ready`. |
| Kubernetes version | All nodes reported `v1.36.5+k3s1`. |
| System services | Cilium/Cilium Envoy, CoreDNS, metrics-server, local-path-provisioner, and cilium-operator were healthy. |
| Metrics | `kubectl top nodes` returned CPU and memory values for all four nodes. |

## Declarative validation

```text
kubectl apply --dry-run=client -k ./manifests/
namespace/homelab created (dry run)
resourcequota/homelab-workload-budget created (dry run)
role.rbac.authorization.k8s.io/namespace-observer created (dry run)
limitrange/homelab-default-resources created (dry run)
```

The actual `kubectl apply -k` created those same four resources. A subsequent `kubectl apply --dry-run=server -k` reported every resource as `unchanged`, proving server-side schema and admission validation succeeds.

## Guardrail test

An intentionally oversized pod (CPU request and limit: `2`) was submitted with `--dry-run=server`. It was rejected as expected:

```text
pods "oversized-cpu-test" is forbidden: maximum cpu usage per Container is 1, but limit is 2
```

Because the request used server-side dry-run, the test pod was never persisted.

## Additional admission validation (2026-10-22)

Two server-side dry-runs provided direct evidence for the remaining namespace controls:

| Control | Test | Result |
| --- | --- | --- |
| `LimitRange` defaults | Submitted a pod with no `resources` block. | API admission injected request `100m` CPU / `128Mi` memory and limit `500m` CPU / `512Mi` memory. |
| Pod Security Admission | Submitted a pod with `securityContext.privileged: true`. | Rejected with `violates PodSecurity "baseline:latest"`; no pod was persisted. |

The default-resource test also generated a warning from the `restricted` audit/warn labels for a non-hardened test container. This is expected: **baseline** is the enforcement level, while **restricted** is intentionally being measured before it is enforced in a later application project.

## Evidence handling

`scripts/collect-cluster-baseline.ps1` generated a local snapshot under `artifacts/`. That directory is ignored by Git and must be reviewed/redacted before any excerpt is committed.

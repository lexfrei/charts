# extractedprism

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.2.0](https://img.shields.io/badge/AppVersion-v0.2.0-informational?style=flat-square)

## Status

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/extractedprism)](https://artifacthub.io/packages/helm/extractedprism/extractedprism)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)

Per-node TCP load balancer for Kubernetes API server high availability

## Overview

extractedprism is a per-node TCP load balancer for Kubernetes API server high availability, inspired by [Talos KubePrism](https://www.talos.dev/latest/kubernetes-guides/configuration/kubeprism/). It runs as a DaemonSet on every node, proxying `localhost:7445` to healthy API server endpoints.

**Key features:**

- **No VIP dependency**: Each node connects to localhost, eliminating VRRP/keepalived single points of failure
- **Two-level discovery**: Static bootstrap endpoints + dynamic Kubernetes EndpointSlice Watch
- **CNI-independent bootstrap**: Uses hostNetwork and static endpoints, works before CNI starts
- **Health-checked upstream**: Only routes to healthy API servers

## TL;DR

```bash
helm install extractedprism oci://ghcr.io/lexfrei/charts/extractedprism \
  --version 0.1.2 \
  --set endpoints="10.0.0.1:6443,10.0.0.2:6443,10.0.0.3:6443"
```

## Prerequisites

- Kubernetes 1.26+
- Helm 3.2.0+

## Installing the Chart

```bash
helm install extractedprism oci://ghcr.io/lexfrei/charts/extractedprism \
  --set endpoints="CP1_IP:6443,CP2_IP:6443,CP3_IP:6443"
```

The `endpoints` value is required and should list all control plane node IPs with the API server port.

## Uninstalling the Chart

```bash
helm uninstall extractedprism
```

## Verifying Chart Signature

```bash
cosign verify \
  ghcr.io/lexfrei/charts/extractedprism:0.1.2 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod assignment |
| bindAddress | string | `"127.0.0.1"` | Address to bind the TCP load balancer listener |
| bindPort | int | `7445` | Port for the TCP load balancer listener |
| dnsPolicy | string | `"ClusterFirstWithHostNet"` | DNS policy (ClusterFirstWithHostNet required when hostNetwork is true) |
| enableDiscovery | bool | `true` | Enable Kubernetes endpoint discovery (watches EndpointSlice API). When true, dynamically discovers API server endpoints in addition to static ones. |
| endpoints | string | `""` | Comma-separated list of control plane endpoints (host:port). Required. These are the static bootstrap endpoints used before Kubernetes API discovery is available (e.g., before CNI starts). |
| fullnameOverride | string | `""` | Override the full name of the chart |
| healthInterval | string | `"20s"` | Interval between upstream health checks |
| healthPort | int | `7446` | Port for the HTTP health check server |
| healthTimeout | string | `"15s"` | Timeout for each upstream health check |
| hostNetwork | bool | `true` | Enable host network mode (required for localhost LB access from kubelet) |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/lexfrei/extractedprism"` | Container image repository |
| image.tag | string | `""` | Container image tag (defaults to chart appVersion if not set) |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"host":"127.0.0.1","path":"/healthz","port":7446},"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe configuration |
| logLevel | string | `"info"` | Log level (debug, info, warn, error) |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selector for pod assignment |
| podAnnotations | object | `{}` | Annotations for pods |
| podLabels | object | `{}` | Additional labels for pods |
| podSecurityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the pod |
| priorityClassName | string | `"system-node-critical"` | Priority class name for pod scheduling |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"host":"127.0.0.1","path":"/readyz","port":7446},"initialDelaySeconds":5,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe configuration |
| resources | object | `{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"10m","memory":"16Mi"}}` | Resource requests and limits |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":65534}` | Security context for the container |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount |
| serviceAccount.create | bool | `true` | Create a ServiceAccount for extractedprism |
| serviceAccount.name | string | `""` | Name of the ServiceAccount (defaults to chart fullname) |
| tolerations | list | `[{"operator":"Exists"}]` | Tolerations for pod assignment. Uses catch-all toleration by default because extractedprism is critical infrastructure that MUST run on every node regardless of any taints. |
| updateStrategy.maxUnavailable | int | `1` | Maximum number of unavailable pods during update |
| updateStrategy.type | string | `"RollingUpdate"` | Update strategy type |

## Architecture

extractedprism runs as a DaemonSet with `hostNetwork: true` on every node. Each pod:

1. Starts a TCP load balancer on `127.0.0.1:7445`
2. Loads static endpoints from `--endpoints` flag (available immediately at boot)
3. Optionally watches Kubernetes EndpointSlice API for dynamic API server discovery
4. Health-checks all upstreams and routes only to healthy ones
5. Exposes `/healthz` (liveness) and `/readyz` (readiness) on port 7446

Configure kubelet on each node to use `https://127.0.0.1:7445` as the API server address.

## Important Notes

- **Host Network**: Required for localhost access from kubelet and other host-level processes
- **Priority Class**: Uses `system-node-critical` to ensure scheduling under resource pressure
- **Security**: Runs as non-root (UID 65534) with read-only filesystem and all capabilities dropped
- **No NET_ADMIN**: Unlike keepalived/VIP solutions, extractedprism needs no special network capabilities

## Links

- [Source Code](https://github.com/lexfrei/extractedprism/)
- [Chart Repository](https://github.com/lexfrei/charts/)
- [Talos KubePrism (inspiration)](https://www.talos.dev/latest/kubernetes-guides/configuration/kubeprism/)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> |  |

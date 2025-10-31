# vipalived

![Version: 0.2.3](https://img.shields.io/badge/Version-0.2.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.22](https://img.shields.io/badge/AppVersion-3.22-informational?style=flat-square)

Keepalived-based VIP management for Kubernetes control plane high availability

## TL;DR

```bash
# Install with default VIP (172.16.101.101/32)
helm install my-vipalived oci://ghcr.io/lexfrei/charts/vipalived --version 0.2.3

# Install with custom VIP address
helm install my-vipalived oci://ghcr.io/lexfrei/charts/vipalived \
  --version 0.2.3 \
  --set keepalived.vrrpInstance.virtualIpAddress=192.168.1.100/24
```

## Introduction

This chart deploys keepalived as a DaemonSet on Kubernetes control plane nodes to provide Virtual IP (VIP) functionality for high availability. It uses VRRP (Virtual Router Redundancy Protocol) to manage IP failover between control plane nodes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Control plane nodes with label `node-role.kubernetes.io/control-plane: "true"`
- Network support for VRRP protocol

## Deployment Scenarios

### Day 2 Operations (Standard Scenario)

This chart is primarily designed for **Day 2 operations** - deploying keepalived on an already running Kubernetes cluster to add or improve high availability.

**Use this when:**

- You already have a working Kubernetes cluster
- You have access to the Kubernetes API server
- You want to manage keepalived through Helm releases
- You need to update/manage keepalived configuration over time

This is the recommended approach for most users and supports full Helm lifecycle management (install, upgrade, rollback).

### Day 1 Bootstrap (Static Pod Scenario)

For **Day 1 cluster bootstrapping**, when you need the VIP available BEFORE the Kubernetes API server is accessible, you can deploy keepalived as a static pod.

**Use this when:**

- You're creating a new HA Kubernetes cluster from scratch
- You need the control plane VIP active during initial `kubeadm init`
- The API server needs to be reachable through the VIP during bootstrap
- You don't have Helm/kubectl access yet (chicken-and-egg problem)

**How to deploy as static pod:**

1. Render the chart to static YAML manifests:

   ```bash
   helm template vipalived oci://ghcr.io/lexfrei/charts/vipalived \
     --version 0.2.3 \
     --set keepalived.vrrpInstance.virtualIpAddress=YOUR_VIP_ADDRESS/CIDR \
     --namespace kube-system > vipalived-manifests.yaml
   ```

2. Extract only the DaemonSet and convert it to a static pod manifest:

   ```bash
   # Extract the DaemonSet spec.template.spec section
   # This contains the pod specification without DaemonSet wrapper
   kubectl apply --dry-run=client -f vipalived-manifests.yaml -o yaml | \
     yq eval 'select(.kind == "DaemonSet") | .spec.template' - > vipalived-pod.yaml
   ```

3. Copy the static pod manifest to each control plane node:

   ```bash
   # On each control plane node
   sudo cp vipalived-pod.yaml /etc/kubernetes/manifests/vipalived.yaml
   ```

4. The kubelet will automatically start the static pod within seconds.

5. Verify the static pod is running:

   ```bash
   # Static pods appear with the node name suffix
   kubectl get pods -n kube-system | grep vipalived
   # Example output: vipalived-control-plane-1
   ```

**Important notes for static pods:**

- Static pods are managed directly by kubelet, not by the API server
- They appear in `kubectl get pods` but cannot be deleted via kubectl
- To update: modify the file in `/etc/kubernetes/manifests/`, kubelet will recreate the pod
- To remove: delete the file from `/etc/kubernetes/manifests/`
- Each control plane node runs its own instance of the static pod
- After cluster bootstrap, you can transition to the Helm-managed DaemonSet for easier management

## Installing the Chart

To install the chart with the release name `my-vipalived`:

```bash
# Basic installation (uses default VIP: 172.16.101.101/32)
helm install my-vipalived oci://ghcr.io/lexfrei/charts/vipalived

# Installation with custom VIP address (recommended for production)
helm install my-vipalived oci://ghcr.io/lexfrei/charts/vipalived \
  --set keepalived.vrrpInstance.virtualIpAddress=YOUR_VIP_ADDRESS/CIDR
```

**Important**: Configure `keepalived.vrrpInstance.virtualIpAddress` to match your network requirements. The [Values](#values) section lists all configurable parameters.

## Uninstalling the Chart

To uninstall/delete the `my-vipalived` deployment:

```bash
helm uninstall my-vipalived
```

## Verifying Chart Signature

All charts published to GHCR are signed using cosign. To verify the chart signature:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/vipalived:0.2.3 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod assignment |
| fullnameOverride | string | `""` | Override the full name of the chart |
| hostNetwork | bool | `true` | Enable host network mode (required for VIP functionality) |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"alpine"` | Container image repository |
| image.tag | string | `""` | Container image tag (defaults to chart appVersion if not set) |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| keepalived.garp.masterDelay | int | `5` | Delay for gratuitous ARP after master transition |
| keepalived.garp.masterRefresh | int | `10` | Interval for gratuitous ARP refresh on master |
| keepalived.garp.masterRefreshRepeat | int | `1` | Number of gratuitous ARP packets to send at refresh |
| keepalived.garp.masterRepeat | int | `5` | Number of gratuitous ARP packets to send at master transition |
| keepalived.routerId | string | `"vipalived"` | Router identifier for keepalived |
| keepalived.vrrpInstance.advertInt | int | `1` | Advertisement interval in seconds |
| keepalived.vrrpInstance.authentication.authPass | string | `"k8s_vip"` | Authentication password (max 8 characters for PASS) |
| keepalived.vrrpInstance.authentication.authType | string | `"PASS"` | Authentication type (PASS or AH) |
| keepalived.vrrpInstance.interface | string | `"eth0"` | Network interface to use for VRRP |
| keepalived.vrrpInstance.name | string | `"VI_CONTROL_PLANE"` | VRRP instance name |
| keepalived.vrrpInstance.nopreempt | bool | `true` | Enable non-preemptive mode |
| keepalived.vrrpInstance.priority | int | `100` | VRRP priority (higher values are preferred) |
| keepalived.vrrpInstance.state | string | `"BACKUP"` | Initial VRRP state (MASTER or BACKUP) |
| keepalived.vrrpInstance.virtualIpAddress | string | `"172.16.101.101/32"` | Virtual IP address with CIDR notation |
| keepalived.vrrpInstance.virtualRouterId | int | `51` | Virtual router ID (must be unique in the network) |
| keepalived.vrrpVersion | int | `3` | VRRP protocol version (2 or 3) |
| nameOverride | string | `""` | Override the name of the chart |
| namespace | string | `"kube-system"` | Namespace to deploy vipalived into |
| nodeSelector | object | `{"node-role.kubernetes.io/control-plane":"true"}` | Node selector for pod assignment |
| podAnnotations | object | `{}` | Annotations for pods |
| podLabels | object | `{}` | Additional labels for pods |
| podSecurityContext | object | `{}` | Security context for the pod |
| priorityClassName | string | `"system-node-critical"` | Priority class name for pod scheduling |
| resources | object | `{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}}` | Resource requests and limits |
| securityContext | object | `{"capabilities":{"add":["NET_ADMIN","NET_RAW","NET_BROADCAST"]}}` | Security context for the container |
| tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"},{"effect":"NoExecute","key":"node.kubernetes.io/not-ready","operator":"Exists"},{"effect":"NoExecute","key":"node.kubernetes.io/unreachable","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/disk-pressure","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/memory-pressure","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/pid-pressure","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/unschedulable","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/network-unavailable","operator":"Exists"}]` | Tolerations for pod assignment |
| updateStrategy.maxUnavailable | int | `1` | Maximum number of unavailable pods during update |
| updateStrategy.type | string | `"RollingUpdate"` | Update strategy type |

## Configuration Examples

### Basic Configuration with Custom VIP

The most important parameter is `virtualIpAddress` - this is the Virtual IP that will float between control plane nodes:

```yaml
keepalived:
  vrrpInstance:
    # REQUIRED: Set your Virtual IP address with CIDR notation
    virtualIpAddress: 192.168.1.100/24

    # Network interface to bind the VIP to
    interface: eth0

    # VRRP priority (higher = preferred master)
    priority: 100

    # Authentication password (max 8 characters)
    authentication:
      authPass: mySecret
```

### High Priority Master Node

```yaml
keepalived:
  vrrpInstance:
    state: MASTER
    priority: 255
    nopreempt: false
    virtualIpAddress: 10.0.0.100/24
```

### Custom GARP Settings for Faster Failover

```yaml
keepalived:
  garp:
    masterDelay: 2
    masterRefresh: 5
    masterRepeat: 10
    masterRefreshRepeat: 2
```

### Custom Resource Limits

```yaml
resources:
  limits:
    cpu: 200m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 64Mi
```

### Additional Tolerations

```yaml
tolerations:
  - key: node.kubernetes.io/custom-taint
    operator: Exists
    effect: NoSchedule
```

## Important Notes

- **Host Network**: This chart requires `hostNetwork: true` to function correctly. The VIP must be accessible on the host network.
- **Security**: The container requires `NET_ADMIN`, `NET_RAW`, and `NET_BROADCAST` capabilities to manage network interfaces and VRRP.
- **Priority Class**: Uses `system-node-critical` to ensure the DaemonSet is scheduled even under resource pressure.
- **Authentication**: The VRRP authentication password (`authPass`) is limited to 8 characters for PASS type authentication.
- **Unique Router ID**: Ensure `virtualRouterId` is unique within your network segment to avoid conflicts.

## Troubleshooting

### VIP Not Coming Up

1. Check that the network interface specified in `keepalived.vrrpInstance.interface` exists on the nodes
2. Verify VRRP protocol is not blocked by network policies or firewalls
3. Check pod logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=vipalived`

### Multiple Masters

If multiple nodes become MASTER:

1. Verify `virtualRouterId` is unique in your network
2. Check network connectivity between nodes
3. Review authentication settings

### Performance Issues

If experiencing slow failover:

1. Adjust GARP settings for faster advertisement
2. Reduce `advertInt` for more frequent health checks
3. Consider increasing container resources

## Links

- [Keepalived Official Documentation](https://www.keepalived.org/)
- [VRRP RFC 5798](https://datatracker.ietf.org/doc/html/rfc5798)
- [Chart Repository](https://github.com/lexfrei/charts/)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> |  |

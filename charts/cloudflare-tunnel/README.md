# cloudflare-tunnel

![Version: 0.15.2](https://img.shields.io/badge/Version-0.15.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2026.1.2](https://img.shields.io/badge/AppVersion-2026.1.2-informational?style=flat-square)

## 📊 Status & Metrics

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/cloudflare-tunnel)](https://artifacthub.io/packages/helm/cloudflare-tunnel/cloudflare-tunnel)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)
[![Helm Version](https://img.shields.io/badge/Helm-v3-informational?logo=helm)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-1.21%2B-blue?logo=kubernetes)](https://kubernetes.io/)

Creation of a cloudflared deployment - a reverse tunnel for an environment

**Homepage:** <https://github.com/lexfrei/charts/>

> **Note**: This chart uses the official Cloudflare Docker image [`cloudflare/cloudflared`](https://hub.docker.com/r/cloudflare/cloudflared) maintained by Cloudflare.

## ✨ Features

- 🚀 **Zero Trust Network Access** - Secure remote access to your Kubernetes services without exposing them to the internet
- 🔄 **Dual Deployment Modes** - Choose between Deployment or DaemonSet for optimal resource utilization
- 📊 **Prometheus Integration** - Built-in ServiceMonitor support for metrics collection
- 🛡️ **Hardened Security** - Non-root containers, read-only filesystem, dropped capabilities
- 🌐 **WARP Routing** - Optional TCP traffic routing through Cloudflare WARP
- ⚖️ **High Availability** - Support for Pod Disruption Budgets and topology spread constraints
- 🔧 **Flexible Configuration** - Comprehensive ingress rules and origin request settings
- 📈 **Production Ready** - Health checks, resource limits, and node affinity support

## 🎯 Use Cases

- Expose internal Kubernetes services securely to the internet
- Create secure tunnels for development and staging environments
- Implement Zero Trust network architecture
- Connect on-premises services to Cloudflare's network
- Enable secure remote access without VPNs

## 🐳 Docker Image

This Helm chart uses the **official Cloudflare Docker image**:

- **Image**: [`cloudflare/cloudflared`](https://hub.docker.com/r/cloudflare/cloudflared)
- **Maintained by**: Cloudflare
- **Auto-updated**: Via Renovate bot to track latest releases
- **Source**: [github.com/cloudflare/cloudflared](https://github.com/cloudflare/cloudflared)

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Cloudflare account with Zero Trust enabled
- Cloudflare Tunnel created and configured

## 🚀 Installation

This chart is published to GitHub Container Registry (GHCR) as an OCI artifact.

### Create Cloudflare Tunnel

Before installing the chart, create a tunnel in Cloudflare:

1. Go to [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Navigate to Networks → Tunnels
3. Create a new tunnel and note the Tunnel ID and Secret

### Install Chart from GHCR

```bash
# Install with inline configuration
helm install cloudflare-tunnel \
  oci://ghcr.io/lexfrei/charts/cloudflare-tunnel \
  --version 0.15.2 \
  --set cloudflare.account=YOUR_ACCOUNT_ID \
  --set cloudflare.tunnelName=YOUR_TUNNEL_NAME \
  --set cloudflare.tunnelId=YOUR_TUNNEL_ID \
  --set cloudflare.secret=YOUR_TUNNEL_SECRET \
  --set cloudflare.ingress[0].hostname=example.com \
  --set cloudflare.ingress[0].service=http://my-service:80

# Install with values file
helm install cloudflare-tunnel \
  oci://ghcr.io/lexfrei/charts/cloudflare-tunnel \
  --version 0.15.2 \
  --values values.yaml
```

### Chart Verification

This chart is signed with [cosign](https://github.com/sigstore/cosign) using keyless signing. Verify the signature before installation:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/cloudflare-tunnel:0.15.2 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

The signature is stored in the [Rekor transparency log](https://rekor.sigstore.dev/) for public verification.

## 📝 Configuration Examples

### Basic HTTP Service

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "my-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  ingress:
    - hostname: app.example.com
      service: http://my-app:8080
```

### Multiple Services with Different Configurations

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "multi-service-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  ingress:
    - hostname: api.example.com
      service: http://api-service:8080
    - hostname: web.example.com
      service: http://web-service:80
    - hostname: admin.example.com
      service: http://admin-service:9000
```

### DaemonSet Mode for Better Resource Distribution

```yaml
deploymentMode: daemonset
cloudflare:
  account: "your-account-id"
  tunnelName: "distributed-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  ingress:
    - hostname: service.example.com
      service: http://my-service:80
```

### Advanced Configuration with Origin Request Settings

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "advanced-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  enableWarp: true
  originRequest:
    connectTimeout: 30s
    tlsTimeout: 10s
    keepAliveTimeout: 90s
    keepAliveConnections: 100
    noTLSVerify: false
  ingress:
    - hostname: secure.example.com
      service: https://backend-service:443
```

### Protocol and Network Configuration

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "protocol-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  # Protocol selection (auto/quic/http2)
  protocol: "quic"
  # Enable post-quantum cryptography for QUIC
  postQuantum: true
  # Cloudflare region selection (us/empty for global)
  region: "us"
  # Connection retries on errors
  retries: 3
  # IP version preference (auto/4/6)
  edgeIpVersion: "auto"
  # Graceful shutdown timeout
  gracePeriod: "30s"
  # Bind outgoing connections to specific IP
  edgeBindAddress: "192.168.1.100"
  # Tags for tunnel identification and monitoring
  tags:
    environment: production
    team: platform
    service: web-frontend
  ingress:
    - hostname: fast.example.com
      service: http://my-service:80
```

### Post-Quantum Cryptography Example

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "quantum-safe-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  # Use QUIC with post-quantum cryptography
  protocol: "quic"
  postQuantum: true
  ingress:
    - hostname: secure.example.com
      service: https://backend:443
```

### Regional Edge Selection

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "us-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  # Force US-based edge servers for compliance
  region: "us"
  # Optimize for IPv4 connectivity
  edgeIpVersion: "4"
  ingress:
    - hostname: us-only.example.com
      service: http://compliance-service:8080
```

### High-Reliability Configuration

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "reliable-tunnel"
  tunnelId: "tunnel-id"
  secret: "tunnel-secret"
  # Aggressive retry policy
  retries: 5
  # Extended graceful shutdown for long-running requests
  gracePeriod: "60s"
  # Tag for monitoring and alerting
  tags:
    criticality: high
    monitoring: enabled
  ingress:
    - hostname: critical.example.com
      service: http://critical-service:80
```

### High Availability Setup

```yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 2

topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: cloudflare-tunnel

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: cloudflare-tunnel
          topologyKey: kubernetes.io/hostname

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Prometheus Monitoring

```yaml
serviceMonitor:
  enabled: true
  interval: 30s
  metricRelabelings:
    - sourceLabels: [__name__]
      regex: 'cloudflared_.*'
      action: keep

metricsPort: 2000
```

### Using Existing Secret

```yaml
cloudflare:
  account: "your-account-id"
  tunnelName: "my-tunnel"
  tunnelId: "tunnel-id"
  secretName: "existing-tunnel-secret"  # Secret should have 'credentials.json' key
  ingress:
    - hostname: app.example.com
      service: http://my-service:80
```

## ⚙️ Advanced Protocol Configuration

### Protocol Selection

The chart supports three transport protocols:

- **`auto`** (default): Automatically selects the best protocol
- **`quic`**: Uses QUIC protocol for improved performance
- **`http2`**: Uses HTTP/2 for compatibility with older networks

### Post-Quantum Cryptography

When using QUIC protocol, you can enable post-quantum cryptography for enhanced security:

```yaml
cloudflare:
  protocol: "quic"
  postQuantum: true
```

**Important**: Post-quantum cryptography is only available with QUIC protocol. The chart includes validation to prevent incompatible combinations.

### Regional Edge Selection

Control which Cloudflare edge servers your tunnel connects to:

- **`""` (empty, default)**: Global edge selection (best performance)
- **`"us"`**: US-only edge servers (compliance requirements)

### IP Version Control

Configure IP version preference for edge connections:

- **`auto`** (default): Automatically select IPv4 or IPv6
- **`4`**: Force IPv4 connections only
- **`6`**: Force IPv6 connections only

### Connection Reliability

Fine-tune connection behavior:

- **`retries`**: Number of connection retries on errors (default: 5)
- **`gracePeriod`**: Graceful shutdown timeout (default: "30s")
- **`edgeBindAddress`**: Bind outgoing connections to specific IP address

### Tagging and Monitoring

Add metadata tags to your tunnel for identification and monitoring:

```yaml
cloudflare:
  tags:
    environment: production
    team: platform
    cost-center: engineering
    monitoring: prometheus
```

## 🔍 Deployment Modes

### Deployment Mode (Default)

- Multiple replicas distributed across nodes
- Better for high availability
- Can scale horizontally
- Default mode for most use cases

### DaemonSet Mode

- One pod per node
- Prevents port exhaustion issues
- Follows Cloudflare's recommendations
- Better for large clusters with many services

To use DaemonSet mode:

```yaml
deploymentMode: daemonset
```

## 🔐 Security

This chart implements several security best practices:

- **Non-root user**: Runs as UID 65532
- **Read-only root filesystem**: Prevents filesystem modifications
- **Dropped capabilities**: All Linux capabilities are dropped
- **No privilege escalation**: Container cannot gain additional privileges

## 📊 Monitoring

The chart exposes Prometheus metrics on port 2000 (configurable via `metricsPort`). When `serviceMonitor.enabled` is set to `true`, a ServiceMonitor resource is created for automatic Prometheus discovery.

Available metrics include:

- `cloudflared_tunnel_total_requests` - Total number of requests
- `cloudflared_tunnel_request_errors` - Number of request errors
- `cloudflared_tunnel_concurrent_requests_per_tunnel` - Current concurrent requests
- And many more...

## 🔧 Troubleshooting

### Tunnel Not Connecting

1. Verify credentials are correct
2. Check if tunnel exists in Cloudflare dashboard
3. Examine pod logs: `kubectl logs -l app.kubernetes.io/name=cloudflare-tunnel`

### Port Exhaustion

If experiencing port exhaustion on nodes:

1. Switch to DaemonSet mode:

   ```yaml
   deploymentMode: daemonset
   ```

2. Reduce number of replicas per node

### Metrics Not Appearing

1. Ensure ServiceMonitor CRD is installed (Prometheus Operator)
2. Verify `serviceMonitor.enabled: true`
3. Check Prometheus is configured to discover ServiceMonitors

## 📚 Useful Links

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflared GitHub Repository](https://github.com/cloudflare/cloudflared)
- [Ingress Rules Configuration](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/configuration-file/ingress)
- [Origin Request Settings](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/configuration-file/ingress#origin-request)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

<!-- markdownlint-disable MD004 -->
## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/cloudflare/cloudflared/>
<!-- markdownlint-enable MD004 -->

## Requirements

Kubernetes: `>=1.21.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Default affinity is to spread out over nodes; use this to override |
| autoscaling | object | `{"behavior":{},"customMetrics":[],"enabled":false,"maxReplicas":10,"minReplicas":2,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":null}` | Horizontal Pod Autoscaler configuration |
| autoscaling.behavior | object | `{}` | Scaling behavior configuration |
| autoscaling.customMetrics | list | `[]` | Custom metrics for autoscaling Example: scale based on cloudflared tunnel metrics |
| autoscaling.enabled | bool | `false` | Enable HPA (only works with deployment mode, not daemonset) |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| autoscaling.minReplicas | int | `2` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilization percentage |
| cloudflare | object | `{"account":"","enableDefault404":true,"enableWarp":false,"ingress":[],"mode":"local","originRequest":{},"secret":"","secretName":null,"tunnelId":"","tunnelName":"","tunnelToken":"","tunnelTokenSecretName":""}` | Cloudflare parameters |
| cloudflare.account | string | `""` | Your Cloudflare account number (local mode only) |
| cloudflare.enableDefault404 | bool | `true` | If true, enable the default 404 page. Needs to be false if you want to use a '*' wildcard rule. |
| cloudflare.enableWarp | bool | `false` | If true, turn on WARP routing for TCP |
| cloudflare.ingress | list | `[]` | Define ingress rules for the tunnel See <https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/configuration-file/ingress> |
| cloudflare.mode | string | `"local"` | Tunnel management mode: "local" or "remote" local: ingress rules defined in values.yaml, stored in ConfigMap remote: ingress rules managed via Cloudflare dashboard/API |
| cloudflare.originRequest | object | `{}` | Global originRequest configuration for all ingress rules See <https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/configuration-file/ingress#origin-request> |
| cloudflare.secret | string | `""` | The secret for the tunnel (local mode only) |
| cloudflare.secretName | string | `nil` | If defined, no secret is created for the credentials (local mode only) |
| cloudflare.tunnelId | string | `""` | The ID of the above tunnel (local mode only) |
| cloudflare.tunnelName | string | `""` | The name of the tunnel this instance will serve (local mode only) |
| cloudflare.tunnelToken | string | `""` | Tunnel token for remote mode (alternative to credentials file) Get from: Zero Trust Dashboard > Networks > Tunnels > Configure |
| cloudflare.tunnelTokenSecretName | string | `""` | Secret name containing tunnel token (key: token) If set, tunnelToken value is ignored |
| deploymentMode | string | `"deployment"` | Deployment mode: "deployment" or "daemonset" DaemonSet mode ensures one tunnel pod per node, useful for: - Preventing port exhaustion from multiple pods on same node - Following Cloudflare's recommendation to limit instances per node - Ensuring predictable distribution and node-level reliability |
| edgeBindAddress | string | `""` | Edge bind address for outgoing connections Specify the outgoing IP address for tunnel connections to Cloudflare edge Useful for multi-homed servers with multiple network interfaces Leave empty to use system default |
| edgeIpVersion | string | `""` | IP version for edge connections (auto, 4, 6) auto: Cloudflare selects optimal IP version automatically 4: Force IPv4 connections to Cloudflare edge 6: Force IPv6 connections to Cloudflare edge Leave empty to use cloudflared default |
| fullnameOverride | string | `""` |  |
| gracePeriod | string | `""` | Graceful shutdown timeout (e.g., 30s, 1m) Time to wait for connections to close gracefully during shutdown Format: number followed by time unit (s for seconds, m for minutes) Leave empty to use cloudflared default |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"cloudflare/cloudflared","tag":""}` | The image to use |
| image.tag | string | `""` | If supplied, this overrides "appVersion" |
| imagePullSecrets | list | `[]` |  |
| livenessProbe | object | `{"failureThreshold":1,"initialDelaySeconds":30,"periodSeconds":10}` | Liveness probe configuration |
| livenessProbe.failureThreshold | int | `1` | Failure threshold for liveness probe |
| livenessProbe.initialDelaySeconds | int | `30` | Initial delay before liveness probe starts |
| livenessProbe.periodSeconds | int | `10` | Period between liveness probe checks |
| logLevel | string | `""` | Log level for cloudflared (debug, info, warn, error, fatal) |
| metricsPort | int | `2000` | Metrics port for Prometheus metrics and readiness probe |
| nameOverride | string | `""` |  |
| networkPolicy | object | `{"egress":[],"enabled":false,"ingress":[]}` | Network Policy configuration |
| networkPolicy.egress | list | `[]` | Additional egress rules (default allows DNS, Cloudflare API/edge, and internal services) |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Additional ingress rules |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget | object | `{"enabled":false,"minAvailable":1}` | Pod Disruption Budget configuration |
| podDisruptionBudget.enabled | bool | `false` | Enable Pod Disruption Budget |
| podDisruptionBudget.minAvailable | int | `1` | Minimum number of available pods (conflicts with maxUnavailable) |
| podLabels | object | `{}` | Additional labels to add to pods |
| podSecurityContext | object | `{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Security items common to everything in the pod.  Here we require that it does not run as the user defined in the image, literally named "nonroot" |
| postQuantum | bool | `false` | Enable post-quantum cryptography for QUIC connections Only works with 'quic' or 'auto' protocol, conflicts with 'http2' See: <https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/cloudflared-parameters/run-parameters/#post-quantum> |
| priorityClassName | string | `""` | Priority class name for pod scheduling priority See <https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/> |
| protocol | string | `""` | Transport protocol for cloudflared (auto, quic, http2) auto: Cloudflare selects the best protocol automatically quic: Force QUIC transport (fastest, most reliable) http2: Force HTTP/2 transport (wider compatibility) Leave empty to use cloudflared default |
| region | string | `""` | Cloudflare region (us for US-only, empty for global) When set to "us", cloudflared will only connect to US Cloudflare edge servers Leave empty for global edge selection |
| replicaCount | int | `2` | The version of the image to use |
| resources | object | `{}` |  |
| retries | string | `""` | Maximum retries for connection/protocol errors Number of retries cloudflared will attempt for network errors Leave empty to use cloudflared default (5) |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Security items for one container. We lock it down |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use If not set and create is true, a name is generated using the fullname template |
| serviceMonitor.enabled | bool | `false` | Enable prometheus Service Monitor |
| serviceMonitor.interval | string | `""` | Scrape interval for Prometheus |
| serviceMonitor.jobLabel | string | `""` | Job label for the ServiceMonitor |
| serviceMonitor.metricRelabelings | list | `[]` | Metric relabelings for the ServiceMonitor |
| serviceMonitor.relabelings | list | `[]` | Relabelings for the ServiceMonitor |
| sidecar | object | `{"containers":[],"extraVolumeMounts":[],"extraVolumes":[],"initContainers":[]}` | Sidecar configuration for additional containers |
| sidecar.containers | list | `[]` | Additional sidecar containers All containers share the same network namespace |
| sidecar.extraVolumeMounts | list | `[]` | Extra volume mounts for the cloudflared container |
| sidecar.extraVolumes | list | `[]` | Extra volumes for sidecar containers |
| sidecar.initContainers | list | `[]` | Init containers to run before main containers |
| tags | object | `{}` | Tags for tunnel identification and monitoring Key-value pairs for tagging tunnel instances in Cloudflare dashboard Useful for grouping, monitoring, and analytics Example: {"environment": "production", "team": "backend"} |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` | Topology spread constraints for pod distribution across zones/nodes See <https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/> |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This chart is licensed under the BSD-3-Clause License.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

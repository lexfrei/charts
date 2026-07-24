# spoolman

![Version: 0.2.4](https://img.shields.io/badge/Version-0.2.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.25.0](https://img.shields.io/badge/AppVersion-0.25.0-informational?style=flat-square)

## 📊 Status & Metrics

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)
[![Helm Version](https://img.shields.io/badge/Helm-v3-informational?logo=helm)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-1.19%2B-blue?logo=kubernetes)](https://kubernetes.io/)

Spoolman filament spool inventory management for 3D printing, packaged for Kubernetes

**Homepage:** <https://github.com/lexfrei/charts/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/Donkie/Spoolman>

## Requirements

Kubernetes: `>=1.19.0-0`

## Installing the Chart

This chart is published to GitHub Container Registry (GHCR) as an OCI artifact.

```bash
# Install from GHCR
helm install spoolman \
  oci://ghcr.io/lexfrei/charts/spoolman \
  --version 0.2.4

# Install with custom values
helm install spoolman \
  oci://ghcr.io/lexfrei/charts/spoolman \
  --version 0.2.4 \
  --values values.yaml
```

### Chart Verification

This chart is signed with [cosign](https://github.com/sigstore/cosign) using keyless signing:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/spoolman:0.2.4 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Uninstalling the Chart

```bash
helm delete spoolman
```

## Security Context Note

The Spoolman image entrypoint starts as `root`, remaps `PUID`/`PGID` and then drops privileges to UID 1000 via `gosu`. Because of this, you must **not** set `securityContext.runAsNonRoot: true` or `securityContext.runAsUser` on the container — doing so prevents the entrypoint from starting. The chart instead sets `fsGroup: 1000` at the pod level so the persistent volume is writable by the application user.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling |
| database | object | `{"existingSecret":"","existingSecretKey":"password","host":"","name":"","password":"","port":"","query":"","type":"sqlite","username":""}` | Database configuration. By default Spoolman uses an embedded SQLite database stored on the persistent volume. Set type to postgres, mysql or cockroachdb to use an external database instead. |
| database.existingSecret | string | `""` | Use an existing Secret for the database password instead of `password` |
| database.existingSecretKey | string | `"password"` | Key within existingSecret that holds the database password |
| database.host | string | `""` | Database host (external databases only) |
| database.name | string | `""` | Database name (external databases only) |
| database.password | string | `""` | Database password (external databases only). When set and existingSecret is empty, this chart creates a Secret to hold it. An inline password is stored in the Helm release history; prefer existingSecret for production. |
| database.port | string | `""` | Database port (external databases only) |
| database.query | string | `""` | Extra connection query parameters (sets SPOOLMAN_DB_QUERY) |
| database.type | string | `"sqlite"` | Database type: sqlite, postgres, mysql or cockroachdb |
| database.username | string | `""` | Database username (external databases only) |
| extraContainers | list | [] | Extra containers to run alongside Spoolman (sidecars) |
| extraEnv | list | [] | Extra environment variables for the container |
| extraVolumeMounts | list | [] | Extra volume mounts for the container |
| extraVolumes | list | [] | Extra volumes to add to the pod (raw Kubernetes volume specs) |
| fullnameOverride | string | `""` |  |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":["spoolman.example.com"],"parentRefs":[{"name":"gateway","namespace":"gateway-system"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]}` | HTTPRoute configuration (Gateway API) |
| httpRoute.hostnames | list | `["spoolman.example.com"]` | Hostnames for the route |
| httpRoute.parentRefs | list | `[{"name":"gateway","namespace":"gateway-system"}]` | Parent Gateway references |
| httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]` | Routing rules |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/donkie/spoolman","tag":""}` | Image configuration |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` |  |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"spoolman.example.com","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[{"hosts":["spoolman.example.com"],"secretName":"spoolman-tls"}]}` | Ingress configuration |
| initContainers | list | [] | Init containers to run before the main container |
| livenessProbe | object | `{"failureThreshold":6,"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe configuration |
| metrics | object | `{"enabled":false,"serviceMonitor":{"enabled":false,"interval":"30s","labels":{},"path":"/metrics","scrapeTimeout":"10s"}}` | Prometheus metrics configuration |
| metrics.enabled | bool | `false` | Enable periodic collection of spool/filament Prometheus gauges (sets SPOOLMAN_METRICS_ENABLED). The /metrics endpoint is always served regardless of this flag; disabling it only omits the spool/filament gauges. |
| metrics.serviceMonitor | object | `{"enabled":false,"interval":"30s","labels":{},"path":"/metrics","scrapeTimeout":"10s"}` | ServiceMonitor for the Prometheus Operator |
| metrics.serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor. Requires metrics.enabled and the Prometheus Operator CRDs to be installed in the cluster. |
| metrics.serviceMonitor.interval | string | `"30s"` | Scrape interval |
| metrics.serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor (e.g. to match a Prometheus selector) |
| metrics.serviceMonitor.path | string | `"/metrics"` | Metrics path. The chart prepends spoolman.basePath automatically. |
| metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout. Must be less than or equal to interval, otherwise the Prometheus Operator rejects the ServiceMonitor. |
| nameOverride | string | `""` |  |
| networkPolicy | object | `{"egress":[],"enabled":false,"ingress":[]}` | Network Policy configuration |
| networkPolicy.egress | list | `[]` | Additional egress rules. Egress to the external database port is added automatically when database.type is not sqlite. |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Additional ingress rules. The built-in rule allows the http port from all namespaces, so the default is permissive; tighten access by adding rules here. |
| nodeSelector | object | `{}` | Node selector for pod scheduling |
| persistence | object | `{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","mountPath":"/home/app/.local/share/spoolman","size":"1Gi","storageClassName":""}` | Persistence for the SQLite database, backups and logs |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.enabled | bool | `true` | Enable persistence (required for the default SQLite database) |
| persistence.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.mountPath | string | `"/home/app/.local/share/spoolman"` | Path inside the container where data is stored. Do not change unless you also override SPOOLMAN_DIR_DATA via extraEnv. |
| persistence.size | string | `"1Gi"` | Size of the volume |
| persistence.storageClassName | string | `""` | Storage class name |
| pgid | int | `1000` | Group ID the application runs as (sets PGID). Also used as the pod fsGroup (unless podSecurityContext.fsGroup is set) so the data volume is writable. |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroupChangePolicy":"OnRootMismatch","seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the pod. fsGroup defaults to pgid so the persistent volume is writable by the application group; set fsGroup here to override. |
| puid | int | `1000` | User ID the application runs as (sets PUID). The image entrypoint starts as root and drops to this UID via gosu. |
| readinessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of replicas. Spoolman is a singleton; keep at 1 when using the default SQLite database or any ReadWriteOnce volume. |
| resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Resource limits and requests |
| securityContext | object | `{}` | Security context for the container. WARNING: the Spoolman image entrypoint starts as root and drops privileges to UID 1000 via gosu. Do NOT set runAsNonRoot: true or runAsUser here or the container will fail to start. Left empty by default on purpose. |
| service | object | `{"annotations":{},"port":80,"type":"ClusterIP"}` | Service configuration |
| service.annotations | object | `{}` | Service annotations |
| service.port | int | `80` | Service port (mapped to the container's http port 8000) |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":false,"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Automount the API token for the service account. Spoolman does not talk to the Kubernetes API, so this defaults to false; set true only if your deployment needs API access. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use |
| spoolman | object | `{"automaticBackup":true,"basePath":"","corsOrigin":"","loggingLevel":""}` | Application-level settings, mapped to SPOOLMAN_* environment variables |
| spoolman.automaticBackup | bool | `true` | Enable nightly automatic SQLite backups (sets SPOOLMAN_AUTOMATIC_BACKUP) |
| spoolman.basePath | string | `""` | Sub-path to host Spoolman under (sets SPOOLMAN_BASE_PATH), e.g. "/spoolman" |
| spoolman.corsOrigin | string | `""` | Allowed CORS origin(s), comma-separated or "*" (sets SPOOLMAN_CORS_ORIGIN) |
| spoolman.loggingLevel | string | `""` | Logging level: DEBUG, INFO, WARNING, ERROR or CRITICAL (sets SPOOLMAN_LOGGING_LEVEL) |
| startupProbe | object | `{"failureThreshold":30,"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":3}` | Startup probe. Generous failureThreshold to allow database migrations on first start. |
| timezone | string | `"UTC"` | Container timezone, set via the TZ environment variable. Honored by the glibc base image for log timestamps; Spoolman itself does not read TZ. |
| tolerations | list | `[]` | Tolerations for pod scheduling |
| updateStrategy | object | `{"type":"Recreate"}` | Update strategy. Recreate avoids two pods mounting the same ReadWriteOnce volume during a rollout. With a ReadWriteMany volume and replicaCount > 1, switch to RollingUpdate to avoid downtime on every rollout. |

## Example Configurations

### Basic deployment with Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: spoolman.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: spoolman-tls
      hosts:
        - spoolman.example.com
```

### Using Gateway API (HTTPRoute)

```yaml
httpRoute:
  enabled: true
  hostnames:
    - spoolman.example.com
  parentRefs:
    - name: my-gateway
      namespace: gateway-system
```

### External PostgreSQL database

```yaml
database:
  type: postgres
  host: postgres.databases.svc.cluster.local
  port: 5432
  name: spoolman
  username: spoolman
  # Reference the DB password from an existing Secret (recommended):
  existingSecret: spoolman-db
  existingSecretKey: password
  # ...or set it inline and the chart creates the Secret for you:
  # password: "change-me"

# SQLite persistence is not needed with an external database
persistence:
  enabled: false
```

### Prometheus metrics with a ServiceMonitor

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      release: kube-prometheus-stack
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

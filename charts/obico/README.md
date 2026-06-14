# obico

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2026.1.20](https://img.shields.io/badge/AppVersion-2026.1.20-informational?style=flat-square)

## 📊 Status & Metrics

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/obico)](https://artifacthub.io/packages/helm/obico/obico)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)
[![Helm Version](https://img.shields.io/badge/Helm-v3-informational?logo=helm)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-1.21%2B-blue?logo=kubernetes)](https://kubernetes.io/)

Self-hosted Obico server for AI-powered 3D printer monitoring (OctoPrint/Klipper)

**Homepage:** <https://github.com/lexfrei/charts/>

## About

[Obico](https://www.obico.io/) (formerly The Spaghetti Detective) is a self-hosted server that adds remote access, webcam streaming and AI-powered failure detection to OctoPrint and Klipper 3D printers.

This chart deploys the full stack:

* **web** — Django application served by Daphne (API, frontend, websockets)
* **tasks** — Celery worker + beat scheduler (runs in the same pod as web)
* **ml-api** — Flask/Gunicorn AI inference service for print-failure detection
* **redis** — bundled Celery broker / Django Channels layer / cache

The container images are built from obico-server source and published to GHCR ([lexfrei/images](https://github.com/lexfrei/images)); the chart tracks new builds automatically.

The ML inference API is heavy (a CUDA-based image). Set `mlApi.enabled: false` to skip it — this disables AI print-failure detection (Obico's headline feature) but keeps remote access, webcam streaming and notifications working.

## Images and auto-update

Obico upstream does not publish ready-to-run images, so they are built from source in a separate repository. Both `obico-web` and `obico-ml-api` are built from one obico commit and share a single calendar-version tag (the chart `appVersion`). Renovate watches the image tag and bumps the chart automatically.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/lexfrei/images/>
* <https://github.com/TheSpaghettiDetective/obico-server/>

## Requirements

Kubernetes: `>=1.21.0-0`

## Installing the Chart

This chart is published to GitHub Container Registry (GHCR) as an OCI artifact.

```bash
# Install from GHCR
helm install obico \
  oci://ghcr.io/lexfrei/charts/obico \
  --version 0.1.0

# Install with custom values
helm install obico \
  oci://ghcr.io/lexfrei/charts/obico \
  --version 0.1.0 \
  --values values.yaml
```

### Chart Verification

This chart is signed with [cosign](https://github.com/sigstore/cosign) using keyless signing:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/obico:0.1.0 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Uninstalling the Chart

```bash
helm uninstall obico
```

The data and media PVCs are annotated with `helm.sh/resource-policy: keep` and survive uninstall. Delete them manually if you no longer need the data.

## Secret key (read before using GitOps)

Obico needs a stable Django `SECRET_KEY`. Rotating it logs every user out and breaks signed tokens. Leaving `obico.secretKey` empty is only safe for a throwaway `helm install`: the empty-value fallback reuses the live Secret on upgrades, but **regenerates the key on every render-only path** — `helm template`, `--dry-run`, `helm diff` and ArgoCD (which renders with `helm template` and never reads the cluster). Under ArgoCD this rotates the key on every sync.

For GitOps, do one of the following:

```yaml
# Set a stable key directly (e.g. openssl rand -base64 48)
obico:
  secretKey: "your-long-random-string"
```

```yaml
# Or reference a Secret you manage (sealed-secrets, external-secrets, ...)
# It must contain DJANGO_SECRET_KEY and any other sensitive env vars.
obico:
  existingSecret: obico-secrets
```

## Database

The default configuration uses SQLite on the data volume so the chart installs with no external dependencies. **SQLite is for evaluation only:** the web server and the Celery worker are separate processes writing the same database file, so under real load they hit `database is locked` errors. Upstream Obico ships PostgreSQL only. For anything beyond a quick try-out, point `database.url` at an external PostgreSQL, or reference a Secret:

```yaml
# Plain connection string
database:
  url: "postgresql://obico:password@postgres:5432/obico"
```

```yaml
# Connection string from an existing Secret
database:
  existingSecret: obico-db
  existingSecretKey: DATABASE_URL
```

## Exposing the Web UI

Either classic Ingress or Gateway API (HTTPRoute) can be used. Remember to set `obico.siteUsesHttps=true` when serving over HTTPS — Django 4 rejects HTTPS form posts (login, signup, admin) from untrusted origins. The chart derives `CSRF_TRUSTED_ORIGINS` automatically from the enabled ingress hosts / HTTPRoute hostnames using that scheme; override with `obico.csrfTrustedOrigins` if you front the app with a different hostname.

```yaml
# Ingress
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: obico.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: obico-tls
      hosts:
        - obico.example.com
obico:
  siteUsesHttps: true
```

```yaml
# Gateway API
httpRoute:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: gateway-system
  hostnames:
    - obico.example.com
obico:
  siteUsesHttps: true
```

## Scaling notes

The web pod runs a single replica because the default SQLite database lives on a ReadWriteOnce volume. It uses the `Recreate` update strategy, so every upgrade or config change tears the pod down before starting the new one — expect a brief outage on each rollout. To run multiple replicas, use an external PostgreSQL and a ReadWriteMany media volume.

## Bundled Redis

The bundled Redis (`redis.enabled: true`) is a minimal, **unauthenticated** single instance intended for in-cluster use only. Do not expose it outside the cluster. For a hardened or shared Redis, set `redis.enabled: false` and point `redis.externalUrl` at your own instance.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| database | object | `{"existingSecret":"","existingSecretKey":"DATABASE_URL","url":"sqlite:////data/db.sqlite3"}` | Database configuration. Defaults to SQLite on the data volume. WARNING: SQLite is for evaluation only. The server and the Celery worker run as separate processes writing the same file, so under load they will hit "database is locked" errors. Upstream ships PostgreSQL only. For any real use set url to an external postgresql:// DSN, or reference a Secret via existingSecret/existingSecretKey. |
| database.existingSecret | string | `""` | Use a key from an existing Secret for DATABASE_URL instead of url |
| database.existingSecretKey | string | `"DATABASE_URL"` | Key inside existingSecret holding the DATABASE_URL value |
| database.url | string | `"sqlite:////data/db.sqlite3"` | Database connection string (Django DATABASE_URL) |
| fullnameOverride | string | `""` |  |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":["obico.example.com"],"parentRefs":[{"name":"gateway","namespace":"gateway-system"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]}` | HTTPRoute configuration (Gateway API) |
| httpRoute.hostnames | list | `["obico.example.com"]` | Hostnames for the route |
| httpRoute.parentRefs | list | `[{"name":"gateway","namespace":"gateway-system"}]` | Parent Gateway references |
| httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]` | Routing rules |
| image | object | `{"mlApi":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/lexfrei/obico-ml-api","tag":""},"web":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/lexfrei/obico-web","tag":""}}` | Container images. Built from obico-server source and published to GHCR. Both images share the chart appVersion tag (one obico commit -> one tag). |
| image.mlApi | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/lexfrei/obico-ml-api","tag":""}` | ML inference API image (failure detection) |
| image.mlApi.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| image.web | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/lexfrei/obico-web","tag":""}` | Web application image (Django + Celery) |
| image.web.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` |  |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"obico.example.com","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[{"hosts":["obico.example.com"],"secretName":"obico-tls"}]}` | Ingress configuration |
| mlApi | object | `{"command":["gunicorn","--bind=0.0.0.0:3333","--workers=1","--access-logfile=-","wsgi"],"enabled":true,"replicaCount":1,"resources":{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"500m","memory":"1Gi"}},"securityContext":{}}` | ML inference API (AI failure detection). Heavy image; can be disabled. |
| mlApi.command | list | `["gunicorn","--bind=0.0.0.0:3333","--workers=1","--access-logfile=-","wsgi"]` | Command for the gunicorn inference server |
| mlApi.enabled | bool | `true` | Deploy the ML inference API |
| mlApi.replicaCount | int | `1` | Number of ml-api replicas |
| mlApi.resources | object | `{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"500m","memory":"1Gi"}}` | Resource requests/limits for the ml-api container |
| mlApi.securityContext | object | `{}` | Security context for the ml-api container. Left empty (image default = root) because the upstream CUDA-based ml-api image is not validated to run unprivileged (model cache and runtime expect root). Harden here once confirmed it runs as non-root in your environment. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| obico | object | `{"csrfTrustedOrigins":[],"debug":false,"existingSecret":"","extraEnv":{},"extraSecretEnv":{},"secretKey":"","siteUsesHttps":false}` | Obico application configuration (rendered into the env ConfigMap/Secret) |
| obico.csrfTrustedOrigins | list | `[]` | CSRF trusted origins (Django 4+ rejects HTTPS POSTs from untrusted origins). Leave empty to auto-derive from the enabled ingress hosts / HTTPRoute hostnames using the scheme implied by siteUsesHttps. Set explicitly to override, e.g. ["https://obico.example.com"]. |
| obico.debug | bool | `false` | Enable Django debug mode (never enable in production) |
| obico.existingSecret | string | `""` | Reference a pre-created Secret for sensitive env (must contain DJANGO_SECRET_KEY and any other secret keys). When set, the chart does not create its own Secret and extraSecretEnv is ignored. Recommended for GitOps. |
| obico.extraEnv | object | `{}` | Extra non-sensitive environment variables (key/value) for web and tasks. Chart-managed keys (DATABASE_URL, REDIS_URL, ...) are rejected here. Example: EMAIL_HOST: smtp.example.com |
| obico.extraSecretEnv | object | `{}` | Extra sensitive environment variables (key/value) stored in the Secret. Example: EMAIL_HOST_PASSWORD: s3cr3t |
| obico.secretKey | string | `""` | Django SECRET_KEY. IMPORTANT: leave empty only for a quick `helm install` test. The empty-value fallback reuses the live Secret on upgrades but REGENERATES the key on any render-only path (helm template, --dry-run, helm diff, ArgoCD) — rotating it logs every user out and rolls the pod on every sync. For GitOps set a stable value here (e.g. `openssl rand -base64 48`) or use existingSecret below. |
| obico.siteUsesHttps | bool | `false` | Set to true when the site is served over HTTPS (behind a TLS ingress/gateway) |
| persistence | object | `{"data":{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","retain":true,"size":"1Gi","storageClassName":""},"media":{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","retain":true,"size":"10Gi","storageClassName":""}}` | Persistence configuration |
| persistence.data | object | `{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","retain":true,"size":"1Gi","storageClassName":""}` | Data volume (SQLite database and persistent data) |
| persistence.data.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.data.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.data.retain | bool | `true` | Keep the PVC when the release is uninstalled |
| persistence.data.size | string | `"1Gi"` | Size of the volume |
| persistence.data.storageClassName | string | `""` | Storage class name |
| persistence.media | object | `{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","retain":true,"size":"10Gi","storageClassName":""}` | Media volume (user uploads, webcam frames, timelapses) |
| persistence.media.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.media.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.media.retain | bool | `true` | Keep the PVC when the release is uninstalled |
| persistence.media.size | string | `"10Gi"` | Size of the volume |
| persistence.media.storageClassName | string | `""` | Storage class name |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroup":65534}` | Security context for the pod. fsGroup is load-bearing, not cosmetic: the server, tasks and migrate containers run as non-root (65534, see securityContext below), so the data and media volumes must be group-owned by that gid for them to write the SQLite DB and media files. It also lets the non-root server read the static assets generated by the root collectstatic init container. Keep them aligned. |
| redis | object | `{"enabled":true,"externalUrl":"","image":{"pullPolicy":"IfNotPresent","repository":"redis","tag":"7.2-alpine"},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"64Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true,"runAsUser":999}}` | Bundled Redis (Celery broker + Django Channels + cache) |
| redis.enabled | bool | `true` | Deploy a minimal in-cluster Redis. Disable to use an external Redis. |
| redis.externalUrl | string | `""` | External Redis URL, used when redis.enabled is false |
| redis.image | object | `{"pullPolicy":"IfNotPresent","repository":"redis","tag":"7.2-alpine"}` | Redis image (pinned; not tied to the chart appVersion) |
| redis.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | Resource requests/limits for the redis container |
| redis.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true,"runAsUser":999}` | Security context for the redis container |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security context for the server, tasks and migrate containers |
| service | object | `{"mlApi":{"annotations":{},"port":3333,"type":"ClusterIP"},"web":{"annotations":{},"port":3334,"type":"ClusterIP"}}` | Service configuration |
| service.mlApi | object | `{"annotations":{},"port":3333,"type":"ClusterIP"}` | ML inference API service (internal) |
| service.mlApi.annotations | object | `{}` | Annotations for the ml-api service |
| service.mlApi.port | int | `3333` | HTTP port |
| service.mlApi.type | string | `"ClusterIP"` | Service type for the ml-api |
| service.web | object | `{"annotations":{},"port":3334,"type":"ClusterIP"}` | Web UI / API service (ClusterIP for Ingress/HTTPRoute) |
| service.web.annotations | object | `{}` | Annotations for the web service |
| service.web.port | int | `3334` | HTTP port |
| service.web.type | string | `"ClusterIP"` | Service type for the web UI |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use |
| tasks | object | `{"command":["celery","-A","config","worker","--beat","-l","info","-c","2","-Q","realtime,celery"],"resources":{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}}` | Celery worker (runs in the same pod as the web server) |
| tasks.command | list | `["celery","-A","config","worker","--beat","-l","info","-c","2","-Q","realtime,celery"]` | Command for the Celery worker with beat scheduler |
| tasks.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests/limits for the tasks container |
| tolerations | list | `[]` |  |
| web | object | `{"command":["daphne","-b","0.0.0.0","-p","3334","config.routing:application"],"resources":{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}}` | Web pod configuration (server + tasks containers, plus init containers) |
| web.command | list | `["daphne","-b","0.0.0.0","-p","3334","config.routing:application"]` | Command for the Daphne ASGI server (serves API, frontend and websockets) |
| web.resources | object | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests/limits for the server container |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

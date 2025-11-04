# transmission

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.0.6](https://img.shields.io/badge/AppVersion-4.0.6-informational?style=flat-square)

## 📊 Status & Metrics

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/transmission)](https://artifacthub.io/packages/helm/transmission/transmission)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)
[![Helm Version](https://img.shields.io/badge/Helm-v3-informational?logo=helm)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-1.19%2B-blue?logo=kubernetes)](https://kubernetes.io/)

Transmission BitTorrent client Helm chart for Kubernetes

**Homepage:** <https://github.com/lexfrei/charts/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/transmission/transmission>
* <https://github.com/linuxserver/docker-transmission>

## Requirements

Kubernetes: `>=1.19.0-0`

## Installing the Chart

This chart is published to GitHub Container Registry (GHCR) as an OCI artifact.

```bash
# Install from GHCR
helm install transmission \
  oci://ghcr.io/lexfrei/charts/transmission \
  --version 1.1.0

# Install with custom values
helm install transmission \
  oci://ghcr.io/lexfrei/charts/transmission \
  --version 1.1.0 \
  --values values.yaml
```

### Chart Verification

This chart is signed with [cosign](https://github.com/sigstore/cosign) using keyless signing:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/transmission:1.1.0 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Uninstalling the Chart

```bash
helm delete transmission
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| env | object | `{"PGID":"1000","PUID":"1000","TZ":"Europe/Moscow"}` | Environment variables for Transmission container |
| env.PGID | string | `"1000"` | Group ID to run as |
| env.PUID | string | `"1000"` | User ID to run as |
| env.TZ | string | `"Europe/Moscow"` | Timezone |
| fullnameOverride | string | `""` |  |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":["transmission.example.com"],"parentRefs":[{"name":"gateway","namespace":"gateway-system"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]}` | HTTPRoute configuration (Gateway API) |
| httpRoute.hostnames | list | `["transmission.example.com"]` | Hostnames for the route |
| httpRoute.parentRefs | list | `[{"name":"gateway","namespace":"gateway-system"}]` | Parent Gateway references |
| httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/"}}]}]` | Routing rules |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"linuxserver/transmission","tag":""}` | Image configuration |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` |  |
| ingress | object | `{"annotations":{"cert-manager.io/cluster-issuer":"cloudflare-issuer","traefik.ingress.kubernetes.io/router.entrypoints":"websecure"},"className":"","enabled":false,"hosts":[{"host":"transmission.example.com","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[{"hosts":["transmission.example.com"],"secretName":"transmission-tls"}]}` | Ingress configuration |
| initContainers | list | [] | Init containers to run before the main container |
| nameOverride | string | `""` |  |
| networkPolicy | object | `{"egress":[],"enabled":false,"ingress":[]}` | Network Policy configuration |
| networkPolicy.egress | list | `[]` | Additional egress rules |
| networkPolicy.enabled | bool | `false` | Enable NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Additional ingress rules |
| nodeSelector | object | `{}` |  |
| persistence | object | `{"config":{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","size":"1Gi","storageClassName":""},"downloads":{"accessMode":"ReadWriteMany","enabled":true,"existingClaim":"","nfsPath":"/mnt/downloads","nfsServer":"nfs-server.example.com","size":"100Gi","storageClassName":"","type":"nfs"}}` | Persistence configuration |
| persistence.config | object | `{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","size":"1Gi","storageClassName":""}` | Config volume configuration |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.config.existingClaim | string | `""` | If you want to use an existing PVC |
| persistence.config.size | string | `"1Gi"` | Size of the volume |
| persistence.config.storageClassName | string | `""` | Storage class name |
| persistence.downloads | object | `{"accessMode":"ReadWriteMany","enabled":true,"existingClaim":"","nfsPath":"/mnt/downloads","nfsServer":"nfs-server.example.com","size":"100Gi","storageClassName":"","type":"nfs"}` | Downloads volume configuration |
| persistence.downloads.accessMode | string | `"ReadWriteMany"` | Access mode (when type is pvc) |
| persistence.downloads.existingClaim | string | `""` | Existing claim (when type is pvc) |
| persistence.downloads.nfsPath | string | `"/mnt/downloads"` | NFS path (when type is nfs) |
| persistence.downloads.nfsServer | string | `"nfs-server.example.com"` | NFS server (when type is nfs) |
| persistence.downloads.size | string | `"100Gi"` | Size (when type is pvc) |
| persistence.downloads.storageClassName | string | `""` | Storage class (when type is pvc) |
| persistence.downloads.type | string | `"nfs"` | Type of storage (pvc or nfs) |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroup":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the pod |
| resources | object | `{"limits":{"cpu":"400m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource limits and requests |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["SETUID","SETGID","CHOWN"],"drop":["ALL"]},"readOnlyRootFilesystem":false}` | Security context for the container |
| service | object | `{"torrent":{"annotations":{"metallb.io/address-pool":"transmission-pool"},"enabled":true,"tcpPort":51413,"type":"LoadBalancer","udpPort":51413},"web":{"annotations":{},"port":9091,"type":"ClusterIP"}}` | Service configuration |
| service.torrent | object | `{"annotations":{"metallb.io/address-pool":"transmission-pool"},"enabled":true,"tcpPort":51413,"type":"LoadBalancer","udpPort":51413}` | Separate LoadBalancer service for torrent ports |
| service.torrent.annotations | object | `{"metallb.io/address-pool":"transmission-pool"}` | Annotations for torrent service (e.g., Cilium LB-IPAM) |
| service.torrent.enabled | bool | `true` | Enable separate torrent service |
| service.torrent.tcpPort | int | `51413` | Torrent TCP port |
| service.torrent.type | string | `"LoadBalancer"` | Service type for torrent traffic |
| service.torrent.udpPort | int | `51413` | Torrent UDP port |
| service.web | object | `{"annotations":{},"port":9091,"type":"ClusterIP"}` | Main service for Web UI (ClusterIP for HTTPRoute/Ingress) |
| service.web.annotations | object | `{}` | Annotations for Web UI service |
| service.web.port | int | `9091` | HTTP port |
| service.web.type | string | `"ClusterIP"` | Service type for Web UI |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use |
| tolerations | list | `[]` |  |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy |

## Example Configurations

### Using NFS for downloads

```yaml
persistence:
  downloads:
    type: nfs
    nfsServer: your-nfs-server.local
    nfsPath: /mnt/downloads
```

### Using PVC for downloads

```yaml
persistence:
  downloads:
    type: pvc
    storageClassName: your-storage-class
    size: 500Gi
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

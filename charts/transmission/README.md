# transmission

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.0.6](https://img.shields.io/badge/AppVersion-4.0.6-informational?style=flat-square)

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

## Installing the Chart

```bash
helm repo add lexfrei https://lexfrei.github.io/charts
helm install transmission lexfrei/transmission
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
| image | object | `{"pullPolicy":"IfNotPresent","repository":"linuxserver/transmission","tag":""}` | Image configuration |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` |  |
| ingress | object | `{"annotations":{"cert-manager.io/cluster-issuer":"cloudflare-issuer","traefik.ingress.kubernetes.io/router.entrypoints":"websecure"},"className":"","enabled":true,"hosts":[{"host":"transmission.home.lex.la","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[{"hosts":["transmission.home.lex.la"],"secretName":"transmission-tls"}]}` | Ingress configuration |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence | object | `{"config":{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","size":"1Gi","storageClassName":"truenas-nfs-csi"},"downloads":{"accessMode":"ReadWriteMany","enabled":true,"existingClaim":"","nfsPath":"/mnt/pool/Transmission","nfsServer":"truenas.home.lex.la","size":"100Gi","storageClassName":"","type":"nfs"}}` | Persistence configuration |
| persistence.config | object | `{"accessMode":"ReadWriteOnce","enabled":true,"existingClaim":"","size":"1Gi","storageClassName":"truenas-nfs-csi"}` | Config volume configuration |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.config.existingClaim | string | `""` | If you want to use an existing PVC |
| persistence.config.size | string | `"1Gi"` | Size of the volume |
| persistence.config.storageClassName | string | `"truenas-nfs-csi"` | Storage class name |
| persistence.downloads | object | `{"accessMode":"ReadWriteMany","enabled":true,"existingClaim":"","nfsPath":"/mnt/pool/Transmission","nfsServer":"truenas.home.lex.la","size":"100Gi","storageClassName":"","type":"nfs"}` | Downloads volume configuration |
| persistence.downloads.accessMode | string | `"ReadWriteMany"` | Access mode (when type is pvc) |
| persistence.downloads.existingClaim | string | `""` | Existing claim (when type is pvc) |
| persistence.downloads.nfsPath | string | `"/mnt/pool/Transmission"` | NFS path (when type is nfs) |
| persistence.downloads.nfsServer | string | `"truenas.home.lex.la"` | NFS server (when type is nfs) |
| persistence.downloads.size | string | `"100Gi"` | Size (when type is pvc) |
| persistence.downloads.storageClassName | string | `""` | Storage class (when type is pvc) |
| persistence.downloads.type | string | `"nfs"` | Type of storage (pvc or nfs) |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"fsGroup":1000}` | Security context for the pod |
| resources | object | `{"limits":{"cpu":"400m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource limits and requests |
| securityContext | object | `{}` | Security context for the container |
| service | object | `{"annotations":{"metallb.io/address-pool":"transmission-pool"},"httpPort":9091,"torrentTCPPort":51413,"torrentUDPPort":51413,"type":"LoadBalancer"}` | Service configuration |
| service.annotations | object | `{"metallb.io/address-pool":"transmission-pool"}` | Service annotations |
| service.httpPort | int | `9091` | HTTP port |
| service.torrentTCPPort | int | `51413` | Torrent TCP port |
| service.torrentUDPPort | int | `51413` | Torrent UDP port |
| service.type | string | `"LoadBalancer"` | Service type |
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

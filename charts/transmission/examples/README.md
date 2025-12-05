# Transmission Helm Chart Examples

This directory contains example values files for common deployment scenarios.

## Quick Start

Use any of these examples with:

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-<scenario>.yaml \
  --namespace media \
  --create-namespace
```

## Examples

### 1. NFS Storage (`values-nfs.yaml`)

**Use case**: You have a dedicated NFS server for media storage.

**Features**:
- Direct NFS mount to downloads directory
- No PVC creation needed
- Best for existing NFS infrastructure

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-nfs.yaml \
  --namespace media
```

**Configuration**:
- Set `persistence.downloads.type: nfs`
- Specify NFS server and path
- `existingClaim` must be empty

---

### 2. Automatic PVC Creation (`values-pvc-automatic.yaml`)

**Use case**: Let Helm create and manage a dedicated PVC for Transmission.

**Features**:
- Automatic PVC creation via chart
- Uses your cluster's storage class (e.g., Longhorn, Ceph)
- Isolated storage for Transmission only

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-pvc-automatic.yaml \
  --namespace media
```

**Configuration**:
- Set `persistence.downloads.type: pvc`
- Configure storage class and size
- `existingClaim` must be empty

---

### 3. Shared Storage with Existing PVC (`values-shared-storage.yaml`) ⭐

**Use case**: Share storage between Transmission and other media apps (Jellyfin, Plex, Sonarr, Radarr).

**Features**:
- Single source of truth for downloaded media
- No data duplication between apps
- Immediate availability in media servers
- Can use custom NFS mountOptions at PV level

**Prerequisites**:

1. Create a shared PVC first:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-media-storage
  namespace: media
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 2Ti
```

2. Apply the PVC:

```bash
kubectl apply -f shared-media-pvc.yaml
```

3. Install Transmission with the shared PVC:

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-shared-storage.yaml \
  --namespace media
```

**Configuration**:
- **IMPORTANT**: `persistence.downloads.type` MUST be `pvc`
- Set `existingClaim` to your PVC name
- Other PVC fields (size, storageClassName) are ignored

**Validation**:

The chart will fail if you try to use `existingClaim` with `type: nfs`:

```yaml
# ❌ INVALID - Will fail validation
persistence:
  downloads:
    type: nfs
    existingClaim: "my-pvc"  # Error!

# ✅ VALID
persistence:
  downloads:
    type: pvc
    existingClaim: "my-pvc"
```

---

### 4. VPN Sidecar with Gluetun (`values-vpn-sidecar.yaml`) 🔒

**Use case**: Route all Transmission traffic through a VPN for privacy.

**Features**:
- Gluetun VPN client as sidecar container
- All torrent traffic goes through VPN tunnel
- Supports OpenVPN and WireGuard
- Works with most VPN providers

**Prerequisites**:

1. Create a secret with VPN credentials:

```bash
# For OpenVPN
kubectl create secret generic gluetun-config \
  --from-literal=OPENVPN_USER=your-username \
  --from-literal=OPENVPN_PASSWORD=your-password \
  --namespace media

# For WireGuard
kubectl create secret generic gluetun-config \
  --from-literal=WIREGUARD_PRIVATE_KEY=your-private-key \
  --from-literal=WIREGUARD_ADDRESSES=10.x.x.x/32 \
  --namespace media
```

2. Install Transmission with VPN sidecar:

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-vpn-sidecar.yaml \
  --namespace media
```

**Configuration**:
- Modify `VPN_SERVICE_PROVIDER` for your provider
- See [gluetun wiki](https://github.com/qdm12/gluetun-wiki) for provider-specific settings
- Adjust `FIREWALL_OUTBOUND_SUBNETS` for your cluster network

---

### 5. Production Configuration (`values-production.yaml`) 🚀

**Use case**: Full production deployment with security, monitoring, and shared storage.

**Features**:
- Shared storage with other media apps
- Ingress with TLS (Let's Encrypt)
- Network policies for security
- Init containers for permissions
- Resource limits and requests
- Anti-affinity for HA

```bash
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-production.yaml \
  --namespace media
```

**Includes**:
- SSL/TLS termination
- Basic auth via Traefik middleware
- Network policies (Ingress/Egress)
- Permission fix init container
- Resource limits
- Pod anti-affinity

---

## Common Scenarios

### Migrating from NFS to Shared PVC

1. Create PVC and copy data:

```bash
# Create PVC
kubectl apply -f shared-media-pvc.yaml

# Copy data from NFS to PVC (using a temporary pod)
kubectl run -n media --rm -it copy-data \
  --image=alpine:latest \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "copy-data",
      "image": "alpine:latest",
      "command": ["sh"],
      "volumeMounts": [
        {"name": "nfs", "mountPath": "/source"},
        {"name": "pvc", "mountPath": "/dest"}
      ]
    }],
    "volumes": [
      {"name": "nfs", "nfs": {"server": "nfs-server.local", "path": "/mnt/downloads"}},
      {"name": "pvc", "persistentVolumeClaim": {"claimName": "shared-media-storage"}}
    ]
  }
}' -- sh -c "cp -av /source/* /dest/"
```

2. Upgrade Transmission to use PVC:

```bash
helm upgrade transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-shared-storage.yaml \
  --namespace media
```

### Sharing with Jellyfin

Both apps use the same PVC:

```yaml
# Transmission
persistence:
  downloads:
    type: pvc
    existingClaim: "shared-media-storage"

# Jellyfin (in its values.yaml)
persistence:
  media:
    enabled: true
    existingClaim: "shared-media-storage"
    mountPath: /media
```

---

## Testing Examples

Validate example files before deployment:

```bash
# Test rendering
helm template transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-shared-storage.yaml

# Dry-run installation
helm install transmission oci://ghcr.io/lexfrei/charts/transmission \
  --values examples/values-shared-storage.yaml \
  --namespace media \
  --dry-run
```

---

## Troubleshooting

### Error: "existingClaim can only be used with type 'pvc'"

**Problem**: You set `existingClaim` with `type: nfs`.

**Solution**: Change `type` to `pvc`:

```yaml
persistence:
  downloads:
    type: pvc  # Changed from nfs
    existingClaim: "my-pvc"
```

### Error: "value must be 'pvc'"

**Problem**: Schema validation caught invalid configuration before template rendering.

**Solution**: Same as above - ensure `type: pvc` when using `existingClaim`.

### Permission Denied Issues

**Problem**: Transmission can't write to shared storage.

**Solution**: Use init container to fix permissions (see `values-production.yaml`):

```yaml
initContainers:
  - name: fix-permissions
    image: busybox:1.36
    command: ['sh', '-c', 'chown -R 1000:1000 /downloads']
    volumeMounts:
      - name: downloads
        mountPath: /downloads
    securityContext:
      runAsUser: 0
```

---

## More Information

- [Main README](../README.md)
- [Chart Repository](https://github.com/lexfrei/charts)
- [Transmission Documentation](https://transmissionbt.com/)

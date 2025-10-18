# system-upgrade-controller

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.17.0](https://img.shields.io/badge/AppVersion-v0.17.0-informational?style=flat-square)

## 📊 Status & Metrics

[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)

Kubernetes-native upgrade controller for nodes using declarative Plans

**Homepage:** <https://github.com/lexfrei/charts/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/rancher/system-upgrade-controller/>

## Introduction

This chart deploys the [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) on a Kubernetes cluster using the Helm package manager. The System Upgrade Controller is a Kubernetes-native upgrade controller that enables automated upgrades of cluster nodes through declarative Plans.

## Features

- Declarative node upgrade plans using Custom Resource Definitions (CRDs)
- Automated rolling upgrades with configurable concurrency
- Node drain and cordon support
- Suitable for k3s, RKE2, and other Kubernetes distributions
- Highly configurable job parameters
- Full RBAC support

## Installing the Chart

### From OCI Registry (GHCR)

This chart is published to GitHub Container Registry as an OCI artifact.

```bash
# Install latest version
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller

# Install specific version
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.1.0

# Install with custom values
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.1.0 \
  --values custom-values.yaml
```

### Chart Verification

This chart is signed with [cosign](https://github.com/sigstore/cosign) using keyless signing. Verify the signature before installation:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/system-upgrade-controller:0.1.2 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

The signature is stored in the [Rekor transparency log](https://rekor.sigstore.dev/) for public verification.

## Uninstalling the Chart

```bash
helm delete system-upgrade-controller
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists"},{"key":"kubernetes.io/os","operator":"In","values":["linux"]}]}]}},"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app.kubernetes.io/name","operator":"In","values":["system-upgrade-controller"]}]},"topologyKey":"kubernetes.io/hostname"}]}}` | Affinity for the controller deployment |
| controller | object | `{"debug":false,"leaderElect":true,"name":"system-upgrade-controller","threads":2}` | Controller configuration |
| controller.debug | bool | `false` | Enable debug logging |
| controller.leaderElect | bool | `true` | Enable leader election |
| controller.name | string | `"system-upgrade-controller"` | Controller name (from metadata labels) |
| controller.threads | int | `2` | Number of threads for the controller |
| crd | object | `{"install":true}` | CRD installation |
| crd.install | bool | `true` | Install the CRD (Plans) |
| fullnameOverride | string | `""` |  |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"rancher/system-upgrade-controller","tag":""}` | Image configuration |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` |  |
| job | object | `{"activeDeadlineSeconds":900,"backoffLimit":99,"imagePullPolicy":"Always","kubectlImage":"rancher/kubectl:v1.34.1","privileged":true,"ttlSecondsAfterFinish":900}` | Job configuration for upgrade plans |
| job.activeDeadlineSeconds | int | `900` | Active deadline seconds for jobs |
| job.backoffLimit | int | `99` | Backoff limit for job failures |
| job.imagePullPolicy | string | `"Always"` | Image pull policy for upgrade jobs |
| job.kubectlImage | string | `"rancher/kubectl:v1.34.1"` | kubectl image for upgrade jobs |
| job.privileged | bool | `true` | Run upgrade jobs as privileged |
| job.ttlSecondsAfterFinish | int | `900` | TTL seconds after job finish |
| nameOverride | string | `""` |  |
| namespace | object | `{"create":true,"name":"system-upgrade"}` | Namespace where the controller will be deployed |
| namespace.create | bool | `true` | Create the namespace |
| namespace.name | string | `"system-upgrade"` | Name of the namespace |
| nodeSelector | object | `{}` | Node selector for the controller deployment |
| plan | object | `{"pollingInterval":"15m"}` | Plan polling configuration |
| plan.pollingInterval | string | `"15m"` | Polling interval for checking plan updates |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security context for the pod |
| resources | object | `{}` | Resource limits and requests |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the container |
| serviceAccount | object | `{"annotations":{},"create":true,"name":"system-upgrade"}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `"system-upgrade"` | The name of the service account to use |
| tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/controlplane","operator":"Exists"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane","operator":"Exists"},{"effect":"NoExecute","key":"node-role.kubernetes.io/etcd","operator":"Exists"}]` | Tolerations for the controller deployment |

## Example Configurations

### Basic k3s Upgrade Plan

After installing the controller, create a Plan to upgrade k3s:

```yaml
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: k3s-server
  namespace: system-upgrade
spec:
  concurrency: 1
  cordon: true
  nodeSelector:
    matchExpressions:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
  serviceAccountName: system-upgrade
  upgrade:
    image: rancher/k3s-upgrade
  version: v1.28.5+k3s1
```

### Custom Namespace

```yaml
namespace:
  name: my-upgrade-namespace
  create: true
```

### Increased Job Timeout

```yaml
job:
  activeDeadlineSeconds: 1800  # 30 minutes
  ttlSecondsAfterFinish: 1800
```

### Debug Mode

```yaml
controller:
  debug: true
```

### Disable CRD Installation

If CRDs are managed separately:

```yaml
crd:
  install: false
```

## Configuration and Installation Details

### RBAC

The chart creates the following RBAC resources:
- ClusterRole for controller operations
- ClusterRole for node draining operations
- Role for namespace-scoped job management
- Corresponding bindings for the service account

### Security

The controller runs with a restricted security context:
- Non-root user (UID 65534)
- No privilege escalation
- All capabilities dropped
- RuntimeDefault seccomp profile

### Affinity and Tolerations

By default, the controller is configured to run on control-plane nodes with appropriate tolerations and pod anti-affinity rules.

## Upgrading the Chart

```bash
# Upgrade to latest version
helm upgrade system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller

# Upgrade to specific version
helm upgrade system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.2.0
```

## Resources

- [System Upgrade Controller Documentation](https://github.com/rancher/system-upgrade-controller)
- [k3s Automated Upgrades](https://docs.k3s.io/upgrades/automated)
- [Plan CRD Reference](https://github.com/rancher/system-upgrade-controller/blob/master/pkg/apis/upgrade.cattle.io/v1/types.go)

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

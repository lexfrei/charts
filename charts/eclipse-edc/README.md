# eclipse-edc

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.12.0](https://img.shields.io/badge/AppVersion-0.12.0-informational?style=flat-square)

Eclipse EDC (Eclipse Dataspace Connector) for secure data exchange in EU Data Spaces

**Homepage:** <https://github.com/lexfrei/charts/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/eclipse-edc/Connector>
* <https://github.com/eclipse-edc/Samples>

## Requirements

Kubernetes: `>=1.21.0-0`

## Overview

This Helm chart deploys [Eclipse EDC (Eclipse Dataspace Connector)](https://github.com/eclipse-edc/Connector), a framework for sovereign data exchange in compliance with EU Data Space initiatives.

## Architecture

This chart deploys a **unified connector** that combines Control Plane and Data Plane functionality in a single container. This is based on the [eclipse-edc/Samples](https://github.com/eclipse-edc/Samples) implementation with mock IAM, suitable for development and testing.

**Note**: This connector uses InMemoryVault which is NOT suitable for production. For production deployments, configure HashiCorp Vault or another secure vault solution.

## Installation

```bash
helm install my-edc oci://ghcr.io/lexfrei/charts/eclipse-edc \
  --set connector.config.participantId=my-connector \
  --set connector.config.hostname=edc.example.com
```

### Required Values

| Value | Description |
|-------|-------------|
| `connector.config.participantId` | Unique identifier for this connector in the dataspace |
| `connector.config.hostname` | Public hostname for external access (DSP callbacks) |

## Exposed APIs

The connector exposes 5 HTTP endpoints:

| Port | Path | Description |
|------|------|-------------|
| 8181 | /api | Default API (health checks) |
| 8182 | /management | Management API |
| 8183 | /protocol | DSP Protocol (connector-to-connector) |
| 8184 | /public | Public API (data transfer) |
| 8185 | /control | Control API |

## External Access

### Using HTTPRoute (Gateway API) - Recommended

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
      namespace: gateway-system
  hostnames:
    - edc.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /protocol
      port: 8183
    - matches:
        - path:
            type: PathPrefix
            value: /public
      port: 8184
```

### Using Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: edc.example.com
      paths:
        - path: /protocol
          pathType: Prefix
          port: protocol
        - path: /public
          pathType: Prefix
          port: public
```

### Using Cloudflare Tunnel

For Cloudflare Tunnel access, set the hostname and configure your tunnel to point to the service:

```yaml
connector:
  config:
    hostname: edc.example.com
```

## Secrets Management

For Vault/OpenBao integration, we recommend using [External Secrets Operator (ESO)](https://external-secrets.io/) to sync secrets from your vault to Kubernetes secrets. This chart does not include Vault integration directly.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| connector | object | `{"affinity":{},"config":{"hostname":"","participantId":"","tokenSignerPrivateKeyAlias":"private-key","tokenVerifierPublicKeyAlias":"public-key"},"env":[],"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/lexfrei/edc-connector","tag":""},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"ports":{"control":8185,"default":8181,"management":8182,"protocol":8183,"public":8184},"replicaCount":1,"resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}},"service":{"annotations":{},"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[]}` | Connector configuration |
| connector.affinity | object | `{}` | Affinity rules for pod assignment |
| connector.config | object | `{"hostname":"","participantId":"","tokenSignerPrivateKeyAlias":"private-key","tokenVerifierPublicKeyAlias":"public-key"}` | EDC configuration |
| connector.config.hostname | string | `""` | Public hostname for DSP callback (REQUIRED for external access) Example: edc.example.com |
| connector.config.participantId | string | `""` | Participant ID for this connector (REQUIRED) |
| connector.config.tokenSignerPrivateKeyAlias | string | `"private-key"` | Token signer private key alias in vault |
| connector.config.tokenVerifierPublicKeyAlias | string | `"public-key"` | Token verifier public key alias in vault |
| connector.env | list | `[]` | Additional environment variables |
| connector.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| connector.image.repository | string | `"ghcr.io/lexfrei/edc-connector"` | Connector image repository |
| connector.image.tag | string | `""` | Connector image tag (defaults to appVersion) |
| connector.nodeSelector | object | `{}` | Node selector for pod assignment |
| connector.podAnnotations | object | `{}` | Annotations to add to pods |
| connector.podLabels | object | `{}` | Labels to add to pods |
| connector.ports | object | `{"control":8185,"default":8181,"management":8182,"protocol":8183,"public":8184}` | Connector ports |
| connector.ports.control | int | `8185` | Control API port |
| connector.ports.default | int | `8181` | Default API port |
| connector.ports.management | int | `8182` | Management API port |
| connector.ports.protocol | int | `8183` | Protocol (DSP) port for connector-to-connector communication |
| connector.ports.public | int | `8184` | Public API port for data transfer |
| connector.replicaCount | int | `1` | Number of connector replicas |
| connector.resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests and limits |
| connector.service.annotations | object | `{}` | Service annotations |
| connector.service.type | string | `"ClusterIP"` | Service type |
| connector.serviceAccount.annotations | object | `{}` | Service account annotations |
| connector.serviceAccount.create | bool | `true` | Create a service account |
| connector.serviceAccount.name | string | `""` | Service account name (generated if not set) |
| connector.tolerations | list | `[]` | Tolerations for pod assignment |
| fullnameOverride | string | `""` | Override the full release name |
| httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":[],"parentRefs":[{"name":"gateway","namespace":"gateway-system"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/protocol"}}],"port":8183},{"matches":[{"path":{"type":"PathPrefix","value":"/public"}}],"port":8184}]}` | HTTPRoute configuration (Gateway API) |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |
| httpRoute.enabled | bool | `false` | Enable HTTPRoute |
| httpRoute.hostnames | list | `[]` | Hostnames for the route |
| httpRoute.parentRefs | list | `[{"name":"gateway","namespace":"gateway-system"}]` | Parent gateway references |
| httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/protocol"}}],"port":8183},{"matches":[{"path":{"type":"PathPrefix","value":"/public"}}],"port":8184}]` | Routing rules (each rule routes to a specific service port) |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[],"tls":[]}` | Ingress configuration |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts | list | `[]` | Ingress hosts configuration |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| nameOverride | string | `""` | Override the chart name |
| podSecurityContext | object | `{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context |

## Security

This chart follows security best practices:

* Runs as non-root user (UID 65532)
* Read-only root filesystem
* Drops all capabilities
* Uses seccomp RuntimeDefault profile
* ServiceAccount tokens not auto-mounted

## Multi-Architecture Support

The container images support both `linux/amd64` and `linux/arm64` architectures, making this chart suitable for Raspberry Pi and ARM-based Kubernetes clusters.

## Links

* [Eclipse EDC Repository](https://github.com/eclipse-edc/Connector)
* [Eclipse EDC Samples](https://github.com/eclipse-edc/Samples)
* [Eclipse EDC Documentation](https://eclipse-edc.github.io/)
* [EU Data Spaces](https://dssc.eu/)

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

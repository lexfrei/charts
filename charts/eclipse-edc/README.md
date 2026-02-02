# eclipse-edc

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.10.1](https://img.shields.io/badge/AppVersion-0.10.1-informational?style=flat-square)

Eclipse EDC (Eclipse Dataspace Connector) for secure data exchange in EU Data Spaces

**Homepage:** <https://github.com/lexfrei/charts/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| lexfrei | <f@lex.la> | <https://github.com/lexfrei> |

## Source Code

* <https://github.com/lexfrei/charts/>
* <https://github.com/eclipse-edc/Connector>

## Requirements

Kubernetes: `>=1.21.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.4.1 |

## Overview

This Helm chart deploys [Eclipse EDC (Eclipse Dataspace Connector)](https://github.com/eclipse-edc/Connector), a framework for sovereign data exchange in compliance with EU Data Space initiatives.

## Architecture

The chart deploys two main components:

- **Control Plane**: Handles management, policy negotiation, and contract management
- **Data Plane**: Handles actual data transfer between participants

Both components can be enabled/disabled independently using feature flags.

## Installation

```bash
helm install my-edc oci://ghcr.io/lexfrei/charts/eclipse-edc \
  --set controlPlane.config.participantId=my-connector \
  --set postgresql.external.host=postgres.example.com \
  --set postgresql.external.existingSecret=postgres-credentials
```

## PostgreSQL Configuration

EDC requires PostgreSQL for persistence. You have two options:

### Option 1: External PostgreSQL (Recommended for Production)

```yaml
postgresql:
  enabled: false
  external:
    host: "postgres.example.com"
    port: 5432
    database: "edc"
    existingSecret: "postgres-credentials"
    existingSecretPasswordKey: "password"
    existingSecretUsernameKey: "username"
```

### Option 2: Deploy PostgreSQL Subchart

```yaml
postgresql:
  enabled: true
  auth:
    database: "edc"
    username: "edc"
    password: "your-password"
```

## Secrets Management

For Vault/OpenBao integration, we recommend using [External Secrets Operator (ESO)](https://external-secrets.io/) to sync secrets from your vault to Kubernetes secrets. This chart does not include Vault integration directly.

Example ESO SecretStore configuration:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "edc"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controlPlane | object | `{"affinity":{},"config":{"participantId":""},"enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"eclipseedc/edc-controlplane","tag":""},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"ports":{"default":8282,"management":8181,"protocol":8182},"replicaCount":1,"resources":{},"service":{"annotations":{},"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[]}` | Control Plane configuration |
| controlPlane.affinity | object | `{}` | Affinity rules for pod assignment |
| controlPlane.config | object | `{"participantId":""}` | EDC Control Plane configuration properties |
| controlPlane.config.participantId | string | `""` | Participant ID for this connector |
| controlPlane.enabled | bool | `true` | Enable Control Plane deployment |
| controlPlane.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| controlPlane.image.repository | string | `"eclipseedc/edc-controlplane"` | Control Plane image repository |
| controlPlane.image.tag | string | `""` | Control Plane image tag (defaults to appVersion) |
| controlPlane.nodeSelector | object | `{}` | Node selector for pod assignment |
| controlPlane.podAnnotations | object | `{}` | Annotations to add to pods |
| controlPlane.podLabels | object | `{}` | Labels to add to pods |
| controlPlane.ports | object | `{"default":8282,"management":8181,"protocol":8182}` | Control Plane ports |
| controlPlane.ports.default | int | `8282` | Default API port |
| controlPlane.ports.management | int | `8181` | Management API port |
| controlPlane.ports.protocol | int | `8182` | Protocol (DSP) port |
| controlPlane.replicaCount | int | `1` | Number of Control Plane replicas |
| controlPlane.resources | object | `{}` | Resource requests and limits |
| controlPlane.service.annotations | object | `{}` | Service annotations |
| controlPlane.service.type | string | `"ClusterIP"` | Service type |
| controlPlane.serviceAccount.annotations | object | `{}` | Service account annotations |
| controlPlane.serviceAccount.create | bool | `true` | Create a service account |
| controlPlane.serviceAccount.name | string | `""` | Service account name (generated if not set) |
| controlPlane.tolerations | list | `[]` | Tolerations for pod assignment |
| dataPlane | object | `{"affinity":{},"config":{},"enabled":true,"image":{"pullPolicy":"IfNotPresent","repository":"eclipseedc/edc-dataplane","tag":""},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"ports":{"control":8186,"public":8185},"replicaCount":1,"resources":{},"service":{"annotations":{},"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[]}` | Data Plane configuration |
| dataPlane.affinity | object | `{}` | Affinity rules for pod assignment |
| dataPlane.config | object | `{}` | EDC Data Plane configuration properties |
| dataPlane.enabled | bool | `true` | Enable Data Plane deployment |
| dataPlane.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| dataPlane.image.repository | string | `"eclipseedc/edc-dataplane"` | Data Plane image repository |
| dataPlane.image.tag | string | `""` | Data Plane image tag (defaults to appVersion) |
| dataPlane.nodeSelector | object | `{}` | Node selector for pod assignment |
| dataPlane.podAnnotations | object | `{}` | Annotations to add to pods |
| dataPlane.podLabels | object | `{}` | Labels to add to pods |
| dataPlane.ports | object | `{"control":8186,"public":8185}` | Data Plane ports |
| dataPlane.ports.control | int | `8186` | Control API port |
| dataPlane.ports.public | int | `8185` | Public API port |
| dataPlane.replicaCount | int | `1` | Number of Data Plane replicas |
| dataPlane.resources | object | `{}` | Resource requests and limits |
| dataPlane.service.annotations | object | `{}` | Service annotations |
| dataPlane.service.type | string | `"ClusterIP"` | Service type |
| dataPlane.serviceAccount.annotations | object | `{}` | Service account annotations |
| dataPlane.serviceAccount.create | bool | `true` | Create a service account |
| dataPlane.serviceAccount.name | string | `""` | Service account name (generated if not set) |
| dataPlane.tolerations | list | `[]` | Tolerations for pod assignment |
| fullnameOverride | string | `""` | Override the full release name |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| nameOverride | string | `""` | Override the chart name |
| podSecurityContext | object | `{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context applied to all pods |
| postgresql | object | `{"auth":{"database":"edc","existingSecret":"","password":"","username":"edc"},"enabled":false,"external":{"database":"edc","existingSecret":"","existingSecretPasswordKey":"password","existingSecretUsernameKey":"username","host":"","port":5432},"primary":{"service":{"ports":{"postgresql":5432}}}}` | PostgreSQL configuration |
| postgresql.auth | object | `{"database":"edc","existingSecret":"","password":"","username":"edc"}` | PostgreSQL subchart auth configuration Only used when postgresql.enabled is true |
| postgresql.auth.existingSecret | string | `""` | Use existing secret for PostgreSQL password |
| postgresql.auth.password | string | `""` | Password for PostgreSQL (auto-generated if not set) |
| postgresql.enabled | bool | `false` | Enable PostgreSQL subchart deployment If false, use external PostgreSQL configuration |
| postgresql.external | object | `{"database":"edc","existingSecret":"","existingSecretPasswordKey":"password","existingSecretUsernameKey":"username","host":"","port":5432}` | External PostgreSQL configuration Used when postgresql.enabled is false |
| postgresql.external.database | string | `"edc"` | Database name |
| postgresql.external.existingSecret | string | `""` | Existing secret name containing PostgreSQL credentials |
| postgresql.external.existingSecretPasswordKey | string | `"password"` | Key in existing secret for password |
| postgresql.external.existingSecretUsernameKey | string | `"username"` | Key in existing secret for username |
| postgresql.external.host | string | `""` | External PostgreSQL host |
| postgresql.external.port | int | `5432` | External PostgreSQL port |
| postgresql.primary | object | `{"service":{"ports":{"postgresql":5432}}}` | PostgreSQL subchart primary configuration |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context applied to all containers |

## Security

This chart follows security best practices:

- Runs as non-root user (UID 65532)
- Read-only root filesystem
- Drops all capabilities
- Uses seccomp RuntimeDefault profile
- ServiceAccount tokens not auto-mounted

## Links

- [Eclipse EDC Repository](https://github.com/eclipse-edc/Connector)
- [Eclipse EDC Documentation](https://eclipse-edc.github.io/)
- [EU Data Spaces](https://dssc.eu/)

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

# Helm Charts Repository

![GitHub Release](https://img.shields.io/github/v/release/lexfrei/charts)
![GitHub Release Date](https://img.shields.io/github/release-date/lexfrei/charts)
[![Lint and Test](https://github.com/lexfrei/charts/actions/workflows/test.yaml/badge.svg)](https://github.com/lexfrei/charts/actions/workflows/test.yaml)
[![License](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://github.com/lexfrei/charts/blob/master/LICENSE)

A collection of Helm charts for Kubernetes deployments, published to GitHub Container Registry (GHCR) as OCI artifacts.

## Available Charts

All charts are published to GHCR with cosign signatures for verification.

### [cloudflare-tunnel](./charts/cloudflare-tunnel)

![Version](https://img.shields.io/badge/version-0.12.6-informational)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.21%2B-blue?logo=kubernetes)

Deploy Cloudflare Tunnel (cloudflared) for secure Zero Trust access to Kubernetes services without exposing inbound ports.

**Key Features:**

- Zero Trust network access with Cloudflare's edge
- Dual deployment modes (Deployment/DaemonSet)
- Prometheus metrics and high availability support
- Hardened security (non-root, read-only filesystem)

[📖 Documentation](./charts/cloudflare-tunnel/README.md) | [🔧 Values](./charts/cloudflare-tunnel/values.yaml)

### [me-site](./charts/me-site)

![Version](https://img.shields.io/badge/version-0.4.3-informational)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.19%2B-blue?logo=kubernetes)

Personal site deployment with HTTPRoute/Gateway API support.

[📖 Documentation](./charts/me-site/README.md) | [🔧 Values](./charts/me-site/values.yaml)

### [system-upgrade-controller](./charts/system-upgrade-controller)

![Version](https://img.shields.io/badge/version-0.1.5-informational)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.16%2B-blue?logo=kubernetes)

Kubernetes-native controller for automated node upgrades using declarative Plans. Based on [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller).

**Key Features:**

- Declarative upgrade plans via CRDs
- Rolling upgrades with concurrency control
- Node drain and cordon automation
- K3s, RKE2, and generic Kubernetes support

[📖 Documentation](./charts/system-upgrade-controller/README.md) | [🔧 Values](./charts/system-upgrade-controller/values.yaml)

### [transmission](./charts/transmission)

![Version](https://img.shields.io/badge/version-0.1.7-informational)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.19%2B-blue?logo=kubernetes)

Transmission BitTorrent client deployment with NFS and PVC storage support.

[📖 Documentation](./charts/transmission/README.md) | [🔧 Values](./charts/transmission/values.yaml)

### [vipalived](./charts/vipalived)

![Version](https://img.shields.io/badge/version-0.3.2-informational)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.16%2B-blue?logo=kubernetes)

VRRP-based Virtual IP management for Kubernetes control plane high availability using keepalived.

**Key Features:**

- Static pod mode for Day 1 cluster bootstrap
- DaemonSet deployment for Day 2 operations
- No CNI dependency (minimal system intrusion)
- Configurable VRRP priority and authentication

[📖 Documentation](./charts/vipalived/README.md) | [🔧 Values](./charts/vipalived/values.yaml)

## Installation

All charts are published to GitHub Container Registry as OCI artifacts.

### Install a Chart

```bash
# Install cloudflare-tunnel chart
helm install my-tunnel \
  oci://ghcr.io/lexfrei/charts/cloudflare-tunnel \
  --version 0.12.6 \
  --values values.yaml

# Install system-upgrade-controller
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.1.5

# Install transmission
helm install transmission \
  oci://ghcr.io/lexfrei/charts/transmission \
  --version 0.1.7

# Install me-site
helm install me-site \
  oci://ghcr.io/lexfrei/charts/me-site \
  --version 0.4.3

# Install vipalived
helm install vipalived \
  oci://ghcr.io/lexfrei/charts/vipalived \
  --version 0.3.2 \
  --set keepalived.vrrpInstance.virtualIpAddress=YOUR_VIP_ADDRESS/CIDR
```

### Verify Chart Signatures

All charts are signed with cosign using keyless signing:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/<chart-name>:<version> \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

Example:

```bash
cosign verify \
  ghcr.io/lexfrei/charts/cloudflare-tunnel:0.12.0 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-oci.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

## Testing

All charts in this repository include comprehensive unit tests using [helm-unittest](https://github.com/helm-unittest/helm-unittest).

### Running Tests Locally

```bash
# Install dependencies
helm plugin install https://github.com/helm-unittest/helm-unittest.git
pip install check-jsonschema

# Run tests
helm unittest charts/cloudflare-tunnel --color

# Validate schema
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml

# Lint chart
helm lint charts/cloudflare-tunnel
```

See [TESTING.md](./TESTING.md) for detailed testing documentation.

### CI/CD

All pull requests automatically run:

- Helm lint
- Schema validation
- Unit tests

Only charts modified in the PR are tested for efficiency.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes following the PR template checklist
4. Submit a pull request

### Chart Development Guidelines

When contributing chart changes:

- **Always bump the chart version** in `Chart.yaml`
- **Update `values.schema.json`** if adding new values
- **Add/update tests** in the `tests/` directory
- **Update the chart README.md** with new parameters
- **Update the changelog** in `Chart.yaml` annotations
- **Follow Helm best practices** for template formatting
- **Test your changes** locally before submitting

## License

[BSD-3-Clause](LICENSE)

## Maintainer

- **Aleksei Sviridkin** - [f@lex.la](mailto:f@lex.la) - [https://me.lex.la](https://me.lex.la)

## Support

- 🐛 **Bug reports**: [Open an issue](https://github.com/lexfrei/charts/issues/new)
- 💡 **Feature requests**: [Open an issue](https://github.com/lexfrei/charts/issues/new)
- 💬 **Questions**: [Open an issue](https://github.com/lexfrei/charts/issues/new)

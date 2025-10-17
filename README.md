# Helm Charts Repository

A collection of Helm charts for Kubernetes deployments, published to GitHub Container Registry (GHCR) as OCI artifacts.

## Available Charts

All charts are published to GHCR with cosign signatures for verification.

### [cloudflare-tunnel](./charts/cloudflare-tunnel)

Helm chart for deploying Cloudflare Tunnel (cloudflared) in Kubernetes. This chart enables secure reverse tunneling to expose your Kubernetes services through Cloudflare's network without opening inbound ports.

**Key Features:**

- Secure tunnel deployment with credential management
- Configurable ingress rules
- ServiceMonitor support for Prometheus metrics
- High availability with replica management
- Security-focused defaults
- OCI artifact with cosign signatures

[📖 Documentation](./charts/cloudflare-tunnel/README.md) | [🔧 Values](./charts/cloudflare-tunnel/values.yaml)

### [me-site](./charts/me-site)

Helm chart for personal site deployment.

[📖 Documentation](./charts/me-site/README.md) | [🔧 Values](./charts/me-site/values.yaml)

### [system-upgrade-controller](./charts/system-upgrade-controller)

Kubernetes-native upgrade controller for automated node upgrades using declarative Plans. Based on [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller).

**Key Features:**

- Declarative node upgrade plans using CRDs
- Automated rolling upgrades with configurable concurrency
- Node drain and cordon support
- Suitable for k3s, RKE2, and other Kubernetes distributions
- Highly configurable job parameters
- OCI artifact with cosign signatures

[📖 Documentation](./charts/system-upgrade-controller/README.md) | [🔧 Values](./charts/system-upgrade-controller/values.yaml)

### [transmission](./charts/transmission)

Helm chart for Transmission BitTorrent client deployment.

[📖 Documentation](./charts/transmission/README.md) | [🔧 Values](./charts/transmission/values.yaml)

## Installation

All charts are published to GitHub Container Registry as OCI artifacts.

### Install a Chart

```bash
# Install cloudflare-tunnel chart
helm install my-tunnel \
  oci://ghcr.io/lexfrei/charts/cloudflare-tunnel \
  --version 0.12.0 \
  --values values.yaml

# Install system-upgrade-controller
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.1.2

# Install transmission
helm install transmission \
  oci://ghcr.io/lexfrei/charts/transmission \
  --version 0.1.3

# Install me-site
helm install me-site \
  oci://ghcr.io/lexfrei/charts/me-site \
  --version 0.4.0
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

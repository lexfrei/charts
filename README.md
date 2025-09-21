# Helm Charts Repository

A collection of Helm charts for Kubernetes deployments.

## Available Charts

### [cloudflare-tunnel](./charts/cloudflare-tunnel)

Helm chart for deploying Cloudflare Tunnel (cloudflared) in Kubernetes. This chart enables secure reverse tunneling to expose your Kubernetes services through Cloudflare's network without opening inbound ports.

**Key Features:**

- Secure tunnel deployment with credential management
- Configurable ingress rules
- ServiceMonitor support for Prometheus metrics
- High availability with replica management
- Security-focused defaults

[📖 Documentation](./charts/cloudflare-tunnel/README.md) | [🔧 Values](./charts/cloudflare-tunnel/values.yaml)

## Installation

### Add Helm Repository

```bash
helm repo add lexfrei https://charts.lex.la
helm repo update
```

### Install a Chart

```bash
# Install cloudflare-tunnel chart
helm install my-tunnel lexfrei/cloudflare-tunnel --values values.yaml
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

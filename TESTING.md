# Testing Guide

This document describes how to run tests for the Helm charts in this repository.

## Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.14+
- [helm-unittest plugin](https://github.com/helm-unittest/helm-unittest)
- [Python 3.12+](https://www.python.org/downloads/) (for schema validation)
- [check-jsonschema](https://pypi.org/project/check-jsonschema/) (for schema validation)

## Quick Start

```bash
# Install dependencies
helm plugin install https://github.com/helm-unittest/helm-unittest.git
pip install check-jsonschema

# Run all checks for cloudflare-tunnel
helm lint charts/cloudflare-tunnel
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml
helm unittest charts/cloudflare-tunnel --color
```

## Running Tests

### Run all tests for a chart

```bash
# For cloudflare-tunnel chart
helm unittest charts/cloudflare-tunnel

# With colored output
helm unittest charts/cloudflare-tunnel --color
```

### Run specific test suites

```bash
# Run only deployment tests
helm unittest charts/cloudflare-tunnel -f 'tests/deployment_test.yaml'

# Run multiple specific tests
helm unittest charts/cloudflare-tunnel -f 'tests/deployment_test.yaml' -f 'tests/configmap_test.yaml'
```

### Validate against JSON schema

```bash
# Validate values.yaml against values.schema.json
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml
```

### Run Helm lint

```bash
# Lint the chart
helm lint charts/cloudflare-tunnel
```

### Template validation (dry-run)

```bash
# Create test values
cat > test-values.yaml << EOF
cloudflare:
  account: "test-account"
  tunnelName: "test-tunnel"
  tunnelId: "test-tunnel-id"
  secret: "test-secret"
  ingress:
    - hostname: test.example.com
      service: http://test-service:80
EOF

# Run template to validate
helm template test-release charts/cloudflare-tunnel -f test-values.yaml
```

## Test Structure

Tests are organized by Kubernetes resource type:

```text
charts/cloudflare-tunnel/tests/
├── all_resources_test.yaml      # Tests for all resources together
├── configmap_test.yaml          # ConfigMap specific tests
├── deployment_test.yaml         # Deployment specific tests
├── secret_test.yaml            # Secret specific tests
├── service_test.yaml           # Service specific tests
├── serviceaccount_test.yaml    # ServiceAccount specific tests
└── servicemonitor_test.yaml    # ServiceMonitor specific tests
```

## Writing New Tests

When adding new features or charts, follow these guidelines:

1. **Create test files** in the `tests/` directory
2. **Name convention**: `<resource>_test.yaml`
3. **Test structure**:

   ```yaml
   suite: test <resource name>
   templates:
     - <template-file>.yaml
   tests:
     - it: should <test description>
       set:
         # Values to override
       asserts:
         # Assertions
         # Assertions
   ```

### Common Assertions

- `isKind`: Check resource kind
- `equal`: Check exact value match
- `matchRegex`: Check regex pattern
- `contains`: Check if array contains item
- `isNotNull`: Check value exists
- `hasDocuments`: Check number of documents

### Example Test

```yamlyaml
suite: test deployment
templates:
  - deployment.yaml
tests:
  - it: should set replica count
    set:
      replicaCount: 3
      cloudflare:
        account: "test"
        tunnelName: "test"
        tunnelId: "test-id"
        secret: "test-secret"
    asserts:
      - equal:
          path: spec.replicas
          value: 3
```

## CI/CD Integration

The repository includes GitHub Actions workflows that automatically:

1. **Detect changed charts** in pull requests
2. **Run linting** with helm lint and chart-testing
3. **Validate schemas** if values.schema.json exists
4. **Run unit tests** with helm-unittest
5. **Run integration tests** in kind cluster (for PRs)

See `.github/workflows/test.yaml` for details.

## Troubleshooting

### helm-unittest plugin not found

```bash
# Check if plugin is installed
helm plugin list

# Reinstall if needed
helm plugin uninstall unittest
helm plugin install https://github.com/helm-unittest/helm-unittest.git
```

### Schema validation fails

Make sure your values.yaml follows the schema defined in values.schema.json:

```bash
# Check what's failing
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml --verbose
```

### Test failures

Run with verbose output:

```bash
helm unittest charts/cloudflare-tunnel --color -d
```

## Additional Resources

- [helm-unittest documentation](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md)
- [Helm best practices](https://helm.sh/docs/chart_best_practices/)
- [JSON Schema documentation](https://json-schema.org/)

# CLAUDE.md - Helm Charts Repository

This file provides repository-specific guidance to Claude Code (claude.ai/code) for working with Helm charts.

**Note**: Global development standards are defined in `~/CLAUDE.md`

## Repository Overview

This is a Helm charts repository containing multiple Kubernetes application charts:
- **cloudflare-tunnel**: Main chart for deploying Cloudflare tunnels
- **frame**: Frame application deployment
- **me-site**: Personal site deployment
- **transmission**: Transmission BitTorrent client deployment

## Development Commands

### Testing Commands

```bash
# Install testing dependencies
helm plugin install https://github.com/helm-unittest/helm-unittest.git
pip install check-jsonschema

# Test a specific chart (e.g., cloudflare-tunnel)
helm lint charts/cloudflare-tunnel
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml
helm unittest charts/cloudflare-tunnel --color

# Test all charts changed in PR
ct list-changed --target-branch master --chart-dirs charts
ct lint --target-branch master --charts <chart-path>

# Validate templates (dry-run)
helm template test-release charts/cloudflare-tunnel -f test-values.yaml
```

### Chart Development Commands

```bash
# Generate README from template (if README.md.gotmpl exists)
helm-docs charts/<chart-name>

# Package chart
helm package charts/<chart-name>

# Update dependencies
helm dependency update charts/<chart-name>
```

### Local Testing Script

Run `./test-workflow.sh` to locally test workflow logic and JSON validation.

### Testing Workflows with Act

Use [nektos/act](https://github.com/nektos/act) to test GitHub Actions workflows locally:

```bash
# Basic workflow testing
act workflow_dispatch --workflows .github/workflows/test.yaml \
  --input charts='["charts/cloudflare-tunnel"]' \
  --platform ubuntu-latest=catthehacker/ubuntu:act-latest \
  --container-architecture linux/amd64

# Test specific job only
act workflow_dispatch --workflows .github/workflows/test.yaml \
  --input charts='["charts/cloudflare-tunnel"]' \
  --platform ubuntu-latest=catthehacker/ubuntu:act-latest \
  --container-architecture linux/amd64 \
  --job detect-changes

# Test push event simulation
echo '{"ref":"refs/heads/master"}' > /tmp/push_master.json
act push --eventpath /tmp/push_master.json \
  --workflows .github/workflows/test.yaml \
  --platform ubuntu-latest=catthehacker/ubuntu:act-latest \
  --container-architecture linux/amd64

# List available jobs
act workflow_dispatch --workflows .github/workflows/test.yaml --list
```

**Recommended Images:**

- **catthehacker/ubuntu:act-latest**: Full Ubuntu environment, best for complex workflows
- **node:16-bullseye**: For Node.js projects
- **node:16-bullseye-slim**: Smaller Node.js image (no Python)

**Important Notes:**

- Always use `--container-architecture linux/amd64` on Apple M-series chips
- Use `--platform ubuntu-latest=IMAGE_NAME` to specify custom images
- The `catthehacker/ubuntu:act-latest` image is specifically designed for act and includes most tools
- Act may have limitations with some GitHub Actions features

## Chart Development Requirements

When modifying charts, you MUST:

1. **Bump chart version** in `Chart.yaml` following semver
2. **Update `artifacthub.io/changes` annotations** in `Chart.yaml` with changelog entries
3. **Update `values.schema.json`** if adding new values
4. **Add/update unit tests** in `tests/` directory using helm-unittest
5. **Update chart README.md** (regenerate with helm-docs if `.gotmpl` template exists)
6. **Test changes locally** before submitting PR using commands above
7. **Run lint and validation** for all changed charts

## Testing Architecture

### Test Structure

- Each chart has a `tests/` directory with resource-specific test files
- Tests use helm-unittest plugin
- Test files follow pattern: `<resource>_test.yaml`
- Common test files: `deployment_test.yaml`, `configmap_test.yaml`, `secret_test.yaml`, etc.

### Required Test Values for cloudflare-tunnel

When testing cloudflare-tunnel templates, always provide these minimum required values:

```yaml
cloudflare:
  account: "test-account"
  tunnelName: "test-tunnel"
  tunnelId: "test-tunnel-id"
  secret: "test-secret"
  ingress:
    - hostname: test.example.com
      service: http://test-service:80
```

## CI/CD Architecture

### GitHub Actions Workflows

- **test.yaml**: Runs lint, tests, and validation on chart changes
- **publish.yaml**: Publishes charts to repository on master branch
- **renovate-update.yaml**: Handles dependency updates

### Change Detection

The test workflow automatically detects changed charts using `ct list-changed` or accepts manual chart specification via `workflow_dispatch` with JSON array input.

### Manual Workflow Dispatch

To manually trigger tests for specific charts:

```bash
# Using GitHub CLI
gh workflow run test.yaml --field charts='["charts/cloudflare-tunnel"]'
```

## Project Structure

```
charts/
├── cloudflare-tunnel/          # Main chart - Cloudflare tunnel deployment
│   ├── Chart.yaml             # Chart metadata and version
│   ├── values.yaml            # Default values
│   ├── values.schema.json     # Values validation schema
│   ├── templates/             # Kubernetes resource templates
│   └── tests/                 # Unit tests
├── frame/                      # Frame application chart
├── me-site/                    # Personal site chart
└── transmission/               # Transmission BitTorrent client chart

.github/
├── workflows/                  # CI/CD workflows
│   ├── test.yaml              # Testing pipeline
│   ├── publish.yaml           # Chart publishing
│   └── renovate-update.yaml   # Dependency updates
├── PULL_REQUEST_TEMPLATE.md    # PR checklist template
└── linters/                    # Linting configuration

test-workflow.sh               # Local testing script for workflow logic
TESTING.md                     # Comprehensive testing documentation
```

## Schema Validation

Charts with `values.schema.json` files automatically undergo schema validation during CI. This ensures `values.yaml` conforms to the defined schema structure.

To validate locally:

```bash
check-jsonschema --schemafile charts/<chart-name>/values.schema.json charts/<chart-name>/values.yaml
```

## Chart Publishing

Charts are automatically published to the Helm repository at `https://charts.lex.la` when changes are merged to the master branch.

Publishing process:

1. PR merged to master triggers publish workflow
2. Chart packages are built
3. Index is updated
4. Charts are pushed to repository

## Helm-Specific Best Practices

### Chart Versioning

- Follow semver strictly
- Document all changes in artifacthub.io/changes annotation
- Never decrease version numbers

### Values Management

- Provide sensible defaults
- Document all values in values.yaml with comments
- Use values.schema.json for validation
- Group related values logically

### Template Guidelines

- Use `include` for reusable template snippets
- Proper indentation with `nindent`
- Always quote string values
- Use `required` for mandatory values
- Add helpful NOTES.txt for post-install instructions

### Testing Guidelines

- Test all chart resources
- Test with different value combinations
- Test upgrade scenarios
- Validate generated manifests
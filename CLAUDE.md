# CLAUDE.md - Helm Charts Repository

This file provides repository-specific guidance to Claude Code (claude.ai/code) for working with Helm charts.

**Note**: Global development standards are defined in `~/CLAUDE.md`

## Repository Overview

This is a Helm charts repository containing multiple Kubernetes application charts:
- **cloudflare-tunnel**: Main chart for deploying Cloudflare tunnels
- **frame**: Frame application deployment
- **me-site**: Personal site deployment
- **system-upgrade-controller**: Kubernetes-native node upgrade controller using declarative Plans
- **transmission**: Transmission BitTorrent client deployment

## Development Commands

### Required Tools Installation

```bash
# Helm plugin for unit testing
helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Python tools for schema validation
pip install check-jsonschema

# Chart testing tool (ct) for linting and testing
# Installation instructions: https://github.com/helm/chart-testing#installation
# macOS:
brew install chart-testing

# helm-docs for README generation from templates
# macOS:
brew install norwoodj/tap/helm-docs
# Linux: download from https://github.com/norwoodj/helm-docs/releases

# Optional: yamllint for YAML validation
pip install yamllint
```

### Testing Commands

```bash
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
   - Breaking changes: bump major version (1.0.0 → 2.0.0)
   - New features: bump minor version (1.0.0 → 1.1.0)
   - Bug fixes: bump patch version (1.0.0 → 1.0.1)

2. **Update `artifacthub.io/changes` annotations** in `Chart.yaml` with changelog entries
   ```yaml
   annotations:
     artifacthub.io/changes: |-
       - kind: added|changed|deprecated|removed|fixed|security
         description: Brief description of the change
   ```
   Valid kinds:
   - `added`: New features or functionality
   - `changed`: Changes in existing functionality
   - `deprecated`: Features marked for removal
   - `removed`: Removed features
   - `fixed`: Bug fixes
   - `security`: Security fixes or improvements

3. **Update `values.schema.json`** if adding new values

4. **Add/update unit tests** in `tests/` directory using helm-unittest

5. **Regenerate README.md** if chart has `README.md.gotmpl` template:
   ```bash
   helm-docs charts/<chart-name>
   # OR using Docker:
   docker run --rm --volume "$(pwd):/helm-docs" jnorwood/helm-docs:v1.14.2 --chart-search-root=/helm-docs/charts/<chart-name>
   ```
   **CRITICAL**: CI will fail if README.md is not up-to-date with the template

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

## Template Helpers Architecture

All charts follow a standard pattern using `_helpers.tpl` for reusable template definitions:

### Standard Helper Templates

Every chart includes these standard helpers in `templates/_helpers.tpl`:

- **`<chart-name>.name`**: Expands chart name, respects `nameOverride`
- **`<chart-name>.fullname`**: Creates fully qualified app name (max 63 chars), respects `fullnameOverride`
- **`<chart-name>.chart`**: Returns chart name and version for labels
- **`<chart-name>.labels`**: Common labels including chart, version, managed-by
- **`<chart-name>.selectorLabels`**: Selector labels for matching pods (name + instance)

### Using Helpers in Templates

```yaml
metadata:
  name: {{ include "cloudflare-tunnel.fullname" . }}
  labels:
    {{- include "cloudflare-tunnel.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "cloudflare-tunnel.selectorLabels" . | nindent 6 }}
```

**Important**: Always use `include` with `nindent` for proper indentation, not `template` or `indent`.

## CI/CD Architecture

### GitHub Actions Workflows

- **test.yaml**: Runs lint, tests, and validation on chart changes
- **publish.yaml**: Publishes charts to GitHub Pages (chart-releaser for legacy charts)
- **publish-system-upgrade-controller.yaml**: Modern OCI + cosign workflow for system-upgrade-controller
- **renovate-update.yaml**: Handles dependency updates

### Change Detection

The test workflow automatically detects changed charts using `ct list-changed` or accepts manual chart specification via `workflow_dispatch` with JSON array input.

### Manual Workflow Dispatch

To manually trigger tests for specific charts:

```bash
# Using GitHub CLI
gh workflow run test.yaml --field charts='["charts/cloudflare-tunnel"]'
```

## Publishing Charts

### Modern OCI Publishing (system-upgrade-controller)

The `system-upgrade-controller` chart uses a modern publishing pipeline with:

**Publishing to GHCR (GitHub Container Registry)**:
- OCI-native Helm chart storage
- Automatic authentication via `docker/login-action` with GITHUB_TOKEN
- No manual credentials needed

**Keyless Signing with cosign**:
- Signatures stored in Rekor transparency log
- GitHub OIDC for ephemeral credentials
- No key management required

**Installation**:
```bash
# Install from GHCR
helm install system-upgrade-controller \
  oci://ghcr.io/lexfrei/charts/system-upgrade-controller \
  --version 0.1.0
```

**Verification**:
```bash
# Verify signature
cosign verify \
  ghcr.io/lexfrei/charts/system-upgrade-controller:0.1.0 \
  --certificate-identity "https://github.com/lexfrei/charts/.github/workflows/publish-system-upgrade-controller.yaml@refs/heads/master" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

**Workflow Features**:
- Validates chart with lint + unittest + schema before publishing
- Checks if version already exists (idempotent)
- Creates GitHub Release with formatted changelog
- Provides installation and verification instructions

**Triggering Publication**:
```bash
# Manual trigger
gh workflow run publish-system-upgrade-controller.yaml

# Automatic: Push changes to charts/system-upgrade-controller/** on master branch
```

### Legacy Publishing (other charts)

Other charts still use `chart-releaser` action publishing to GitHub Pages at `https://charts.lex.la`.

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

## Quick Reference

### Complete Chart Development Workflow

```bash
# 1. Make changes to chart
vim charts/cloudflare-tunnel/values.yaml

# 2. Bump version in Chart.yaml
vim charts/cloudflare-tunnel/Chart.yaml

# 3. Update schema if needed
vim charts/cloudflare-tunnel/values.schema.json

# 4. Regenerate README if .gotmpl exists
helm-docs charts/cloudflare-tunnel

# 5. Run full test suite
helm lint charts/cloudflare-tunnel
check-jsonschema --schemafile charts/cloudflare-tunnel/values.schema.json charts/cloudflare-tunnel/values.yaml
helm unittest charts/cloudflare-tunnel --color

# 6. Dry-run template generation
helm template test-release charts/cloudflare-tunnel -f test-values.yaml
```

### test-workflow.sh Script

Local script for testing workflow logic and JSON validation before pushing:

```bash
./test-workflow.sh
```

This script validates:
- JSON parsing logic used in CI
- YAML syntax in workflow files (requires `yq`)
- Basic workflow structure

Use this to catch workflow issues before committing.

### Common One-Liners

```bash
# List all charts with tests
find charts -name "tests" -type d

# Validate all schemas at once
for chart in charts/*/; do [ -f "$chart/values.schema.json" ] && check-jsonschema --schemafile "$chart/values.schema.json" "$chart/values.yaml"; done

# Lint all charts
for chart in charts/*/; do helm lint "$chart"; done

# Run all tests for all charts
for chart in charts/*/; do [ -d "$chart/tests" ] && helm unittest "$chart" --color; done

# Trigger test workflow for specific chart
gh workflow run test.yaml --field charts='["charts/cloudflare-tunnel"]'
```

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
# Pull Request

## Description
<!-- Briefly describe what this PR does -->

## Type of change
<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Chart version bump

## Checklist

### Required for all PRs

- [ ] I have tested these changes locally
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code

### Required for chart changes

- [ ] Chart version has been bumped in `Chart.yaml`
- [ ] `values.schema.json` has been updated (if new values were added)
- [ ] `README.md` has been updated (if new values were added)
- [ ] `Chart.yaml` changelog has been updated with changes
- [ ] All new values have proper descriptions/comments
- [ ] Tests have been added/updated in `tests/` directory
- [ ] All tests pass locally (`helm unittest charts/<chart-name>`)
- [ ] Schema validation passes (`check-jsonschema --schemafile charts/<chart-name>/values.schema.json charts/<chart-name>/values.yaml`)
- [ ] Helm lint passes (`helm lint charts/<chart-name>`)

### If adding new templates

- [ ] Templates follow Helm best practices
- [ ] Templates use proper indentation (`nindent` instead of `indent`)
- [ ] Conditional rendering uses `{{- if }}` to control whitespace

### If modifying existing functionality

- [ ] Changes are backward compatible OR breaking changes are documented
- [ ] Default values maintain existing behavior

## Additional context
<!-- Add any other context about the PR here -->

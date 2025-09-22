#!/usr/bin/env bash
# Script for local testing of workflow logic

set -e

echo "🧪 Local workflow logic testing"
echo "==============================="

# Test 1: JSON validation check
echo
echo "🔍 Test 1: JSON validation"
test_json='["charts/transmission"]'
if echo "$test_json" | jq . >/dev/null 2>&1; then
    echo "✅ JSON is valid: $test_json"
    parsed=$(echo "$test_json" | jq -r '.[]')
    echo "   Parsed: $parsed"
else
    echo "❌ JSON is invalid: $test_json"
fi

# Test 2: JSON array formation from paths
echo
echo "🔍 Test 2: JSON array formation"
mock_paths="charts/transmission/Chart.yaml
charts/cloudflare-tunnel/Chart.yaml"

echo "Mock paths:"
echo "$mock_paths"

charts_array=$(echo "$mock_paths" | grep 'Chart.yaml$' | sed 's|/Chart.yaml||' | jq -R -s -c 'split("\n") | map(select(length > 0))')
echo "✅ Result: $charts_array"

# Test 3: Empty result check
echo
echo "🔍 Test 3: Empty result"
empty_result=$(echo "" | jq -R -s -c 'split("\n") | map(select(length > 0))')
echo "✅ Empty result: $empty_result"

# Test 4: YAML syntax check (if yq is installed)
echo
echo "🔍 Test 4: YAML files check"
for workflow in .github/workflows/*.yaml; do
    if command -v yq >/dev/null 2>&1; then
        if yq eval . "$workflow" >/dev/null 2>&1; then
            echo "✅ $workflow - YAML syntax is correct"
        else
            echo "❌ $workflow - YAML syntax is incorrect"
        fi
    else
        echo "⚠️  yq not installed, skipping YAML check"
        break
    fi
done

echo
echo "🎉 All tests completed!"
echo
echo "💡 For testing with act (if installed):"
echo "   act workflow_dispatch -W .github/workflows/test.yaml --input charts='[\"charts/transmission\"]'"
echo
echo "💡 For online workflow syntax check:"
echo "   https://rhysd.github.io/actionlint/"

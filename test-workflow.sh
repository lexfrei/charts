#!/usr/bin/env bash
# Скрипт для локального тестирования workflow логики

set -e

echo "🧪 Локальное тестирование workflow логики"
echo "========================================="

# Тест 1: Проверка JSON валидации
echo
echo "🔍 Тест 1: JSON валидация"
test_json='["charts/transmission"]'
if echo "$test_json" | jq . >/dev/null 2>&1; then
    echo "✅ JSON валиден: $test_json"
    parsed=$(echo "$test_json" | jq -r '.[]')
    echo "   Parsed: $parsed"
else
    echo "❌ JSON невалиден: $test_json"
fi

# Тест 2: Проверка формирования JSON из путей
echo
echo "🔍 Тест 2: Формирование JSON массива"
mock_paths="charts/transmission/Chart.yaml
charts/cloudflare-tunnel/Chart.yaml"

echo "Mock paths:"
echo "$mock_paths"

charts_array=$(echo "$mock_paths" | grep 'Chart.yaml$' | sed 's|/Chart.yaml||' | jq -R -s -c 'split("\n") | map(select(length > 0))')
echo "✅ Результат: $charts_array"

# Тест 3: Проверка пустого результата
echo
echo "🔍 Тест 3: Пустой результат"
empty_result=$(echo "" | jq -R -s -c 'split("\n") | map(select(length > 0))')
echo "✅ Пустой результат: $empty_result"

# Тест 4: Проверка YAML синтаксиса (если yq установлен)
echo
echo "🔍 Тест 4: Проверка YAML файлов"
for workflow in .github/workflows/*.yaml; do
    if command -v yq >/dev/null 2>&1; then
        if yq eval . "$workflow" >/dev/null 2>&1; then
            echo "✅ $workflow - YAML синтаксис корректен"
        else
            echo "❌ $workflow - YAML синтаксис некорректен"
        fi
    else
        echo "⚠️  yq не установлен, пропуск проверки YAML"
        break
    fi
done

echo
echo "🎉 Все тесты завершены!"
echo
echo "💡 Для тестирования с act (если установлен):"
echo "   act workflow_dispatch -W .github/workflows/test.yaml --input charts='[\"charts/transmission\"]'"
echo
echo "💡 Для проверки workflow синтаксиса онлайн:"
echo "   https://rhysd.github.io/actionlint/"

#!/usr/bin/env bash
# =============================================================================
# mk/resolve-order.sh — Резолвер зависимостей (топологическая сортировка)
#
# Usage: ./mk/resolve-order.sh <project:profile> [project:profile ...]
# Output: топологически отсортированный список project:profile
#
# Для каждого target:
#   1. Читает ROOT/project/profiles/profile.mk
#   2. Извлекает PF_TOOLCHAIN и PF_DEPS через make -f /dev/stdin
#   3. Рекурсивный DFS с обнаружением циклов
#   4. Вывод: зависимости перед зависимыми
# =============================================================================

set -euo pipefail

# Определяем ROOT — директория выше mk/
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Ассоциативные массивы для DFS
declare -A VISITED    # 0=not visited, 1=in-progress (gray), 2=done (black)
declare -A DEPS_CACHE # кеш PF_TOOLCHAIN+PF_DEPS для каждого project:profile
declare -a ORDER      # результат топологической сортировки

# Извлекает PF_TOOLCHAIN + PF_DEPS из profile-файла через make
get_deps() {
    local project="$1"
    local profile="$2"
    local key="${project}:${profile}"

    # Кеш
    if [[ -v DEPS_CACHE["$key"] ]]; then
        echo "${DEPS_CACHE[$key]}"
        return
    fi

    local profile_file="${ROOT}/${project}/profiles/${profile}.mk"

    if [[ ! -f "$profile_file" ]]; then
        echo "Error: profile file not found: ${profile_file}" >&2
        exit 1
    fi

    # Извлекаем PF_TOOLCHAIN и PF_DEPS через make
    local deps
    deps=$(make -f /dev/stdin --no-print-directory 2>/dev/null <<MAKEOF
include ${profile_file}
.PHONY: _print_deps
_print_deps:
	@echo \$(PF_TOOLCHAIN) \$(PF_DEPS)
MAKEOF
    ) || deps=""

    DEPS_CACHE["$key"]="$deps"
    echo "$deps"
}

# DFS с обнаружением циклов
visit() {
    local key="$1"  # project:profile
    local project="${key%%:*}"
    local profile="${key#*:}"

    # Уже обработан
    if [[ "${VISITED[$key]:-0}" == "2" ]]; then
        return
    fi

    # Обнаружен цикл
    if [[ "${VISITED[$key]:-0}" == "1" ]]; then
        echo "Error: circular dependency detected: ${key}" >&2
        exit 1
    fi

    # Отмечаем как in-progress
    VISITED["$key"]="1"

    # Получаем зависимости (PF_TOOLCHAIN + PF_DEPS)
    local deps
    deps=$(get_deps "$project" "$profile")

    # Рекурсивно обходим зависимости
    for dep in $deps; do
        visit "$dep"
    done

    # Отмечаем как done и добавляем в порядок
    VISITED["$key"]="2"
    ORDER+=("$key")
}

# --- Main ---

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <project:profile> [project:profile ...]" >&2
    echo "Output: topologically sorted list of project:profile" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 openssl:1.1.1w-r1" >&2
    echo "  → gcc:8.5.0-r1 toolchain-gcc:8.5.0-r1 zlib:1.3.1-r1 openssl:1.1.1w-r1" >&2
    exit 1
fi

for target in "$@"; do
    if [[ "$target" != *:* ]]; then
        echo "Error: invalid format '$target', expected project:profile" >&2
        exit 1
    fi
    visit "$target"
done

echo "${ORDER[@]}"

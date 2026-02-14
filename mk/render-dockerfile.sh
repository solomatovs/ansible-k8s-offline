#!/usr/bin/env bash
# =============================================================================
# mk/render-dockerfile.sh — Рендерит Dockerfile-шаблон
#
# Usage: ./mk/render-dockerfile.sh <project> <dockerfile>
# Output: отрендеренный Dockerfile на stdout
#
# Обрабатывает шаблонные ссылки вида:
#   #### <project:profile:region> ####
# Заменяет их содержимым одноимённой области из Dockerfile указанного проекта.
#
# Области в исходных Dockerfile'ах отмечаются парными маркерами:
#   #### region_name ####
#   ... content ...
#   #### region_name ####
#
# Все COPY-пути (без --from) автоматически получают префикс ТЕКУЩЕГО проекта
# (а не проекта-источника региона), так что build context = корень репозитория
# и все исходники берутся из artifacts/src/ текущего проекта.
#
# Пример:
#   ./mk/render-dockerfile.sh openssl Dockerfile > /tmp/rendered.Dockerfile
#   docker build -f /tmp/rendered.Dockerfile -t openssl:1.1.1w-build .
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

PROJECT="$1"
DOCKERFILE="$2"
TEMPLATE="${ROOT}/${PROJECT}/${DOCKERFILE}"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Error: template not found: ${TEMPLATE}" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Определить PF_DOCKERFILE из профиля проекта
# Usage: resolve_dockerfile <project> <profile>
# Выводит имя Dockerfile (по умолчанию "Dockerfile")
# -----------------------------------------------------------------------------
resolve_dockerfile() {
    local project="$1"
    local profile="$2"
    local profile_file="${ROOT}/${project}/profiles/${profile}.mk"

    if [[ -f "$profile_file" ]]; then
        local pf_df
        pf_df=$(sed -n 's/^PF_DOCKERFILE[[:space:]]*=[[:space:]]*//p' "$profile_file" | tr -d '[:space:]')
        if [[ -n "$pf_df" ]]; then
            echo "$pf_df"
            return
        fi
    fi
    echo "Dockerfile"
}

# -----------------------------------------------------------------------------
# Извлечь именованную область из Dockerfile проекта
# Usage: extract_region <project> <profile> <region_name>
# Dockerfile определяется автоматически из profiles/<profile>.mk → PF_DOCKERFILE
# -----------------------------------------------------------------------------
extract_region() {
    local project="$1"
    local profile="$2"
    local region="$3"
    local dockerfile
    dockerfile=$(resolve_dockerfile "$project" "$profile")
    local src="${ROOT}/${project}/${dockerfile}"

    if [[ ! -f "$src" ]]; then
        echo "Error: Dockerfile not found: ${src}" >&2
        exit 1
    fi

    local found=false in_region=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "#### ${region} ####" ]]; then
            if $in_region; then
                return 0        # конец области
            else
                in_region=true
                found=true
                continue        # начало — пропускаем маркер
            fi
        fi
        if $in_region; then
            # Рекурсивная обработка вложенных шаблонных ссылок
            if [[ "$line" =~ ^####\ \<([^:]+):([^:]+):([^>]+)\>\ ####$ ]]; then
                local nest_project="${BASH_REMATCH[1]}"
                local nest_profile="${BASH_REMATCH[2]}"
                local nest_region="${BASH_REMATCH[3]}"
                echo "# --- ${nest_project}:${nest_profile} [${nest_region}] ---"
                extract_region "$nest_project" "$nest_profile" "$nest_region"
                continue
            fi
            # Префиксируем COPY-пути ТЕКУЩИМ проектом (для ROOT контекста)
            # ${PROJECT} — проект верхнего уровня, не ${project} (проект-источник региона)
            if [[ "$line" =~ ^COPY[[:space:]] ]] && [[ ! "$line" =~ --from ]]; then
                echo "COPY ${PROJECT}/${line#COPY }"
            else
                echo "$line"
            fi
        fi
    done < "$src"

    if $in_region; then
        echo "Error: unclosed region '${region}' in ${src}" >&2
        exit 1
    fi
    if ! $found; then
        echo "Error: region '${region}' not found in ${src}" >&2
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Рендеринг шаблона
# -----------------------------------------------------------------------------
while IFS= read -r line || [[ -n "$line" ]]; do

    # --- Шаблонная ссылка: #### <project:profile:region> ####
    if [[ "$line" =~ ^####\ \<([^:]+):([^:]+):([^>]+)\>\ ####$ ]]; then
        ref_project="${BASH_REMATCH[1]}"
        ref_profile="${BASH_REMATCH[2]}"
        ref_region="${BASH_REMATCH[3]}"
        echo "# --- ${ref_project}:${ref_profile} [${ref_region}] ---"
        extract_region "$ref_project" "$ref_profile" "$ref_region"
        continue
    fi

    # --- Маркер области: #### name #### (удаляем из выхода)
    if [[ "$line" =~ ^####\ [^\ ]+\ ####$ ]] && [[ ! "$line" =~ \< ]]; then
        continue
    fi

    # --- Обычная строка: префиксируем COPY для ROOT контекста
    if [[ "$line" =~ ^COPY[[:space:]] ]] && [[ ! "$line" =~ --from ]]; then
        echo "COPY ${PROJECT}/${line#COPY }"
    else
        echo "$line"
    fi

done < "$TEMPLATE"

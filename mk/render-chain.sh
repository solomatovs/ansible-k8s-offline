#!/usr/bin/env bash
# =============================================================================
# mk/render-chain.sh — Генерирует единый multi-stage Dockerfile из цепочки PF_DEPS
#
# Usage: ./mk/render-chain.sh <project> <profile_id>
# Output: полный multi-stage Dockerfile на stdout
#
# Обходит цепочку PF_DEPS рекурсивно, для каждого звена берёт его Dockerfile,
# трансформирует ссылки на внешние образы (FROM ${..._IMAGE}) в ссылки на
# внутренние стадии, и собирает единый self-contained multi-stage Dockerfile.
#
# Конвенции:
#   - Имя переменной версии: ${UC_PROJECT}_VERSION (выводится из PROJECT)
#   - Имя переменной образа: ${UC_PROJECT}_IMAGE (выводится из PROJECT)
#   - Имена стадий: ${PROJECT}-${PF_VERSION} (например golang-1.17.13)
#   - Имя build-стадии: определяется автоматически из Dockerfile (FROM ... AS <name>)
#   - BASE_IMAGE: определяется автоматически из Dockerfile (ARG BASE_IMAGE=...)
#   - Вся структура (apt-get, COPY, ENV) берётся из Dockerfile — ничего не захардкожено
#
# Ограничения:
#   - Поддерживаются только зависимости внутри одного проекта (${PROJECT}:profile_id)
#   - Dockerfile должен иметь не более одной build-стадии (FROM ... AS <name>),
#     не считая dependency-стадий (FROM ${..._IMAGE} AS ...)
#
# Пример:
#   ./mk/render-chain.sh golang 1.24.5 > .rendered.Dockerfile
#   docker build -f .rendered.Dockerfile -t golang:1.24.5-build ..
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

PROJECT="$1"
PROFILE_ID="$2"
PROJECT_DIR="${ROOT}/${PROJECT}"
PROFILES_DIR="${PROJECT_DIR}/profiles"

# UC_PROJECT: golang → GOLANG, toolchain-gcc → TOOLCHAIN_GCC
UC_PROJECT=$(echo "$PROJECT" | tr 'a-z-' 'A-Z_')
VERSION_VAR="${UC_PROJECT}_VERSION"
IMAGE_VAR="${UC_PROJECT}_IMAGE"

# -----------------------------------------------------------------------------
# Чтение переменной из .mk файла
# Usage: read_var <file> <varname>
# Сохраняет внутренние пробелы (важно для PF_DEPS с несколькими значениями)
# -----------------------------------------------------------------------------
read_var() {
    local file="$1" var="$2"
    sed -n "s/^${var}[[:space:]]*=[[:space:]]*//p" "$file" \
        | head -1 | sed 's/[[:space:]]*$//'
}

# -----------------------------------------------------------------------------
# Рекурсивное разрешение цепочки PF_DEPS (от корня к вершине)
# Usage: resolve_chain <profile_id>
# Поддерживает только зависимости внутри одного проекта (${PROJECT}:profile_id).
# Выводит профили в порядке сборки (корень первый, без целевого)
# -----------------------------------------------------------------------------
resolve_chain() {
    local pid="$1"
    local pfile="${PROFILES_DIR}/${pid}.mk"

    if [[ ! -f "$pfile" ]]; then
        echo "Error: ${pfile} not found" >&2
        exit 1
    fi

    local deps
    deps=$(read_var "$pfile" "PF_DEPS")

    for dep in $deps; do
        local dep_project="${dep%%:*}"
        local dep_pid="${dep#*:}"

        if [[ "$dep_project" != "$PROJECT" ]]; then
            echo "Error: cross-project dependency '${dep}' not supported by render-chain (expected ${PROJECT}:...)" >&2
            exit 1
        fi

        resolve_chain "$dep_pid"
        echo "$dep_pid"
    done
}

# -----------------------------------------------------------------------------
# Нахождение строки отсечки для финальной выходной стадии
# Находит последний FROM без AS и сдвигает вверх, захватывая предшествующие
# пустые строки и комментарии (они относятся к выходной стадии).
# Usage: find_cutoff_line <dockerfile>
# Возвращает номер строки для отсечки или пустую строку
# -----------------------------------------------------------------------------
find_cutoff_line() {
    local file="$1"
    local from_line
    from_line=$(grep -n '^FROM ' "$file" | grep -v ' AS ' | tail -1 | cut -d: -f1)
    [[ -z "$from_line" ]] && return

    local lines
    mapfile -t lines < "$file"
    local cutoff="$from_line"

    while (( cutoff > 1 )); do
        local prev="${lines[$((cutoff - 2))]}"
        if [[ -z "$prev" ]] || [[ "$prev" =~ ^[[:space:]]*# ]]; then
            ((cutoff--))
        else
            break
        fi
    done

    echo "$cutoff"
}

# -----------------------------------------------------------------------------
# Нахождение алиаса зависимости (имя после AS в FROM ${IMAGE_VAR})
# Usage: find_dep_alias <dockerfile>
# Пример: FROM ${GOLANG_IMAGE} AS golang-bootstrap → "golang-bootstrap"
# Возвращает алиас или пустую строку
# -----------------------------------------------------------------------------
find_dep_alias() {
    grep -m1 "^FROM.*\\\${${IMAGE_VAR}}.*AS " "$1" 2>/dev/null \
        | sed 's/.* AS //' | tr -d '[:space:]' || true
}

# -----------------------------------------------------------------------------
# Нахождение имени build-стадии (FROM ... AS <name>, исключая dep-стадии)
# Usage: find_build_stage <dockerfile>
# Пример: FROM ${BASE_IMAGE} AS builder → "builder"
# Возвращает имя стадии или пустую строку
# -----------------------------------------------------------------------------
find_build_stage() {
    grep '^FROM.*AS ' "$1" \
        | grep -v "\\\${${IMAGE_VAR}}" \
        | head -1 \
        | sed 's/.* AS //' | tr -d '[:space:]' \
    || true
}

# -----------------------------------------------------------------------------
# Чтение значения по умолчанию BASE_IMAGE из Dockerfile
# Usage: read_base_image <dockerfile>
# Возвращает значение или пустую строку
# -----------------------------------------------------------------------------
read_base_image() {
    sed -n 's/^ARG BASE_IMAGE=//p' "$1" 2>/dev/null \
        | head -1 | tr -d '[:space:]' || true
}

# -----------------------------------------------------------------------------
# Обработка Dockerfile: трансформация ссылок и подстановка версий
#
# Usage: process_dockerfile <dockerfile> <version> <prev_version> [--intermediate]
#
# --intermediate:
#   - Переименовывает "AS <build_stage>" → "AS {PROJECT}-{version}"
#   - Удаляет dependency FROM (FROM ${IMAGE_VAR} AS ...)
#   - Пропускает финальную выходную стадию (последний FROM без AS + предшествующие комментарии)
#   - Заменяет COPY --from=<dep_alias> → COPY --from={PROJECT}-{prev_version}
#   - Заменяет COPY --from=<build_stage> → COPY --from={PROJECT}-{version}
#
# Общее (оба режима):
#   - Удаляет ARG ${IMAGE_VAR}, ARG BASE_IMAGE
#   - Удаляет ARG ${VERSION_VAR}
#   - Удаляет маркеры регионов #### name ####
#   - Подставляет конкретную версию вместо ${UC_PROJECT}_VERSION
#   - Префиксирует COPY-пути (без --from) именем проекта
# -----------------------------------------------------------------------------
process_dockerfile() {
    local src="$1"
    local version="$2"
    local prev_ver="$3"
    local mode="${4:-}"

    # Для промежуточных: найти строку отсечки финальной стадии
    local cutoff_line=""
    if [[ "$mode" == "--intermediate" ]]; then
        cutoff_line=$(find_cutoff_line "$src")
    fi

    # Найти алиас зависимости (напр. golang-bootstrap) для замены --from=
    local dep_alias=""
    dep_alias=$(find_dep_alias "$src")

    # Найти имя build-стадии (напр. builder) для переименования
    local build_stage=""
    build_stage=$(find_build_stage "$src")

    local line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++)) || true

        # Intermediate: пропускаем финальную выходную стадию (и предшествующие комментарии)
        if [[ "$mode" == "--intermediate" ]] && \
           [[ -n "$cutoff_line" ]] && \
           (( line_num >= cutoff_line )); then
            continue
        fi

        # Удаляем ARG ${IMAGE_VAR} (напр. ARG GOLANG_IMAGE)
        if [[ "$line" =~ ^ARG[[:space:]]+${IMAGE_VAR} ]]; then
            continue
        fi

        # Удаляем ARG BASE_IMAGE (уже объявлен в header)
        if [[ "$line" =~ ^ARG[[:space:]]+BASE_IMAGE ]]; then
            continue
        fi

        # Удаляем маркеры регионов #### name ####
        if [[ "$line" =~ ^####\ [^\ ]+\ ####$ ]] && [[ ! "$line" =~ \< ]]; then
            continue
        fi

        # Intermediate: удаляем FROM ${IMAGE_VAR} AS ... (dependency FROM)
        if [[ "$mode" == "--intermediate" ]] && \
           [[ "$line" =~ ^FROM.*\$\{${IMAGE_VAR}\} ]]; then
            continue
        fi

        # Target: заменяем FROM ${IMAGE_VAR} на FROM {PROJECT}-{prev_version}
        if [[ "$line" =~ \$\{${IMAGE_VAR}\} ]]; then
            line="${line//\$\{${IMAGE_VAR}\}/${PROJECT}-${prev_ver}}"
        fi

        # Intermediate: переименовываем AS <build_stage> → AS {PROJECT}-{version}
        if [[ "$mode" == "--intermediate" ]] && [[ -n "$build_stage" ]] && \
           [[ "$line" =~ ^FROM.*\ AS\ ${build_stage}($|[[:space:]]) ]]; then
            line="${line/ AS ${build_stage}/ AS ${PROJECT}-${version}}"
        fi

        # Intermediate: заменяем --from=<dep_alias> → --from={PROJECT}-{prev_version}
        if [[ "$mode" == "--intermediate" ]] && [[ -n "$dep_alias" ]] && [[ -n "$prev_ver" ]] && \
           [[ "$line" =~ --from=${dep_alias} ]]; then
            line="${line//--from=${dep_alias}/--from=${PROJECT}-${prev_ver}}"
        fi

        # Intermediate: заменяем --from=<build_stage> → --from={PROJECT}-{version}
        if [[ "$mode" == "--intermediate" ]] && [[ -n "$build_stage" ]] && \
           [[ "$line" =~ --from=${build_stage} ]]; then
            line="${line//--from=${build_stage}/--from=${PROJECT}-${version}}"
        fi

        # Удаляем ARG ${VERSION_VAR} (напр. ARG GOLANG_VERSION)
        if [[ "$line" =~ ^ARG[[:space:]]+${VERSION_VAR} ]]; then
            continue
        fi

        # Подставляем конкретную версию (только ${VAR} с фигурными скобками —
        # форма $VAR без скобок не поддерживается, т.к. невозможно определить
        # границу имени: $GOLANG_VERSION_EXTRA → 1.24.5_EXTRA)
        line="${line//\$\{${VERSION_VAR}\}/${version}}"

        # Префиксируем COPY-пути (без --from) именем проекта
        if [[ "$line" =~ ^COPY[[:space:]] ]] && [[ ! "$line" =~ --from ]]; then
            echo "COPY ${PROJECT}/${line#COPY }"
        else
            echo "$line"
        fi
    done < "$src"
}

# =============================================================================
# Main
# =============================================================================

target_pfile="${PROFILES_DIR}/${PROFILE_ID}.mk"
if [[ ! -f "$target_pfile" ]]; then
    echo "Error: ${target_pfile} not found" >&2
    exit 1
fi

target_version=$(read_var "$target_pfile" "PF_VERSION")
target_dockerfile=$(read_var "$target_pfile" "PF_DOCKERFILE")
: "${target_dockerfile:=Dockerfile}"

# Резолвим цепочку зависимостей (уникальные, в порядке сборки)
mapfile -t raw_chain < <(resolve_chain "$PROFILE_ID")
chain=()
if [[ ${#raw_chain[@]} -gt 0 ]]; then
    declare -A seen
    for pid in "${raw_chain[@]}"; do
        if [[ -z "${seen[$pid]+x}" ]]; then
            chain+=("$pid")
            seen[$pid]=1
        fi
    done
fi

# Определяем BASE_IMAGE из Dockerfiles (target → первый dep → ошибка)
base_image=$(read_base_image "${PROJECT_DIR}/${target_dockerfile}")
if [[ -z "$base_image" ]] && [[ ${#chain[@]} -gt 0 ]]; then
    for dep_pid in "${chain[@]}"; do
        dep_pfile="${PROFILES_DIR}/${dep_pid}.mk"
        dep_df=$(read_var "$dep_pfile" "PF_DOCKERFILE")
        : "${dep_df:=Dockerfile}"
        base_image=$(read_base_image "${PROJECT_DIR}/${dep_df}")
        [[ -n "$base_image" ]] && break
    done
fi
if [[ -z "$base_image" ]]; then
    echo "Error: BASE_IMAGE not found in any Dockerfile (expected ARG BASE_IMAGE=...)" >&2
    exit 1
fi

# --- Header ---
echo "ARG BASE_IMAGE=${base_image}"
echo ""

# --- Промежуточные стадии ---
prev_version=""
for dep_pid in "${chain[@]}"; do
    dep_pfile="${PROFILES_DIR}/${dep_pid}.mk"
    dep_version=$(read_var "$dep_pfile" "PF_VERSION")
    dep_dockerfile=$(read_var "$dep_pfile" "PF_DOCKERFILE")
    : "${dep_dockerfile:=Dockerfile}"

    echo "# === ${PROJECT} ${dep_version} ==="
    process_dockerfile "${PROJECT_DIR}/${dep_dockerfile}" "$dep_version" "$prev_version" --intermediate
    echo ""

    prev_version="$dep_version"
done

# --- Целевая стадия ---
echo "# === Target: ${PROFILE_ID} ==="
process_dockerfile "${PROJECT_DIR}/${target_dockerfile}" "$target_version" "$prev_version"

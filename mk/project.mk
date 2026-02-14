# =============================================================================
# mk/project.mk — общее ядро для всех проектов (PF_ формат)
#
# Подключение: include ../mk/project.mk (последней строкой Makefile проекта)
#
# Обязательные переменные (задать ДО include):
#   PROJECT      — имя проекта (используется для имени образа)
#   BASE_IMAGE   — базовый Docker-образ
#   _TEST_CMD    — команда тестирования образа
#
# Профиль (profiles/V.mk) должен определять:
#   PF_VERSION     — чистая upstream-версия (обязательно)
#   PF_DOCKERFILE  — имя Dockerfile (обязательно)
#   PF_DEPS        — зависимости project:profile (через пробелы, опционально)
#   PF_SRC_URL     — URL для скачивания исходников (опционально)
#   PF_SRC_FILE    — имя файла исходников (опционально)
#   PF_TEST_CMD    — тестовая команда (переопределяет _TEST_CMD, опционально)
#
# Опциональные (в Makefile проекта):
#   _EXTRA_BUILD_ARGS   — дополнительные --build-arg
#   _EXTRA_SRC_FILES    — дополнительные исходники (make targets для download)
#   _EXTRA_URLS_CMD     — shell-команда для вывода доп. URL (echo "URL FILE";)
#   _EXTRA_CLEAN_FILES  — дополнительные файлы для удаления при clean
#   _HELP_EXTRA         — дополнительные строки для help (shell-команды)
# =============================================================================

# --- Профили (+ dep-хелперы, + обработка PF_DEPS) ---
include ../mk/profiles.mk

# --- Backend (docker/buildah) + стандартные пути артефактов ---
include ../mk/backend.mk

# --- SRC_FILE: авто из PF_SRC_FILE (если не задан в Makefile проекта) ---
ifdef PF_SRC_FILE
SRC_FILE ?= $(ARTIFACTS_SRC)/$(PF_SRC_FILE)
endif

# =============================================================================
# Вычисляемые переменные
# =============================================================================

_UC_PROJECT := $(shell echo '$(PROJECT)' | tr 'a-z-' 'A-Z_')

image_name = $(PROJECT):$(1)-build

_IMAGE  = $(call image_name,$(V))
_LABELS = \
    --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-build \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)

_BUILD_ARGS ?= \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    --build-arg $(_UC_PROJECT)_VERSION=$(PF_VERSION) \
    $(_DEP_BUILD_ARGS) \
    $(_EXTRA_BUILD_ARGS)

_TAR_NAME = $(PROJECT)-$(V)-build.tar

# --- Рендеринг Dockerfile (шаблонные ссылки #### <project:profile:region> ####) ---
_RENDER ?= ../mk/render-dockerfile.sh $(PROJECT) $(PF_DOCKERFILE)
_RENDERED_FILE = .rendered.Dockerfile

# --- Валидация ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите версию (например, make docker/build <version>)"; \
    echo "Поддерживаемые версии: $(VERSIONS)"; exit 1; fi; \
    if [ ! -f profiles/$(V).mk ]; then \
    echo "Ошибка: profiles/$(V).mk не найден"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi; \
    if [ -z "$(PF_DOCKERFILE)" ]; then \
    echo "Ошибка: PF_DOCKERFILE не определён в profiles/$(V).mk"; exit 1; fi

check_src_files = @for f in $(1); do \
    test -f "$$f" || { echo "Ошибка: $$f не найден. Выполните: make download $(V)"; exit 1; }; \
    done

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) build V=$(1)

# =============================================================================
# Targets
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help show-urls download render build export test shell clean
.PHONY: $(VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  show-urls <profile>         Показать URL-ы исходников (для оркестрации)"
	@echo "  download  <profile>         Скачать исходники $(PROJECT) (требует интернет)"
	@echo "  render    <profile>         Показать отрендеренный Dockerfile (stdout)"
	@echo "  build     <profile>         Собрать образ и экспортировать в artifacts/images/"
	@echo "  export    <profile>         Архивировать артефакты в artifacts/build/"
	@echo "  test      <profile>         Проверить артефакты"
	@echo "  shell     <profile>         Shell в образе"
	@echo "  clean     [profile]         Удалить образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(VERSIONS)"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
ifdef _HELP_EXTRA
	@echo ""
	@$(_HELP_EXTRA)
endif
	@echo ""
	@echo "  Флаги:"
	@echo "    FORCE=1                   Пересборка без кеша (--no-cache)"
	@echo "    BACKEND=docker|buildah    Выбор backend (по умолчанию: buildah)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/build $(firstword $(VERSIONS))"
	@echo "    make docker/test  $(firstword $(VERSIONS))"
	@echo "    make docker/build $(firstword $(VERSIONS)) FORCE=1"

# --- Список URL-ов для скачивания (рекурсивно по PF_DEPS) ---
show-urls:
	$(call check_version)
	@{ $(MAKE) --no-print-directory _list_urls V=$(V) DEST=$(PROJECT)/$(ARTIFACTS_SRC); $(_EXTRA_URLS_CMD) } | sort -u

# --- Скачивание исходников (рекурсивно через _download_to) ---
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
ifdef _EXTRA_SRC_FILES
	@$(MAKE) $(_EXTRA_SRC_FILES)
endif

# --- Рендеринг Dockerfile (сохраняет на диск, перезаписывает) ---
render:
	$(call check_version)
	@$(_RENDER) > $(_RENDERED_FILE)
	@cat $(_RENDERED_FILE)

# --- Сборка образа (проверка наличия исходников перед сборкой) ---
build:
	$(call check_version)
	@$(MAKE) --no-print-directory _check_src V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
	$(call check_src_files,$(_EXTRA_SRC_FILES))
	@$(_RENDER) > $(_RENDERED_FILE)
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_RENDERED_FILE) \
	  -t $(_IMAGE) ..
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

# --- Экспорт артефактов ---
export:
	$(call check_version)
	$(call ensure,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/$(PROJECT)-$(V).tar.gz)

# --- Тестирование ---
test:
	$(call check_version)
	$(call ensure,$(V))
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),$(or $(PF_TEST_CMD),$(_TEST_CMD)))

# --- Shell в образе ---
shell:
	$(call check_version)
	$(call ensure,$(V))
	@$(call _shell,$(_IMAGE))

# --- Очистка ---
clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/$(PROJECT)-$(V).tar.gz; \
	  rm -f $(SRC_FILE) $(_EXTRA_SRC_FILES) $(_EXTRA_CLEAN_FILES) $(_RENDERED_FILE); \
	else \
	  for v in $(VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: версия как цель (например, make docker/build 1.1.0)
$(VERSIONS):
	@:

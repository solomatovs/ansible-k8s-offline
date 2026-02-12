# =============================================================================
# mk/project.mk — общее ядро для всех проектов (PF_ формат)
#
# Подключение: include ../mk/project.mk (последней строкой Makefile проекта)
#
# Обязательные переменные (задать ДО include):
#   PROJECT      — имя проекта (используется для имени образа)
#   BASE_IMAGE   — базовый Docker-образ
#   SRC_FILE     — путь к архиву исходников, e.g. $(ARTIFACTS_SRC)/zlib-$(PF_VERSION).tar.gz
#   _TEST_CMD    — команда тестирования образа
#
# Профиль (profiles/V.mk) должен определять:
#   PF_VERSION     — чистая upstream-версия (обязательно)
#   PF_DOCKERFILE  — имя Dockerfile (обязательно)
#   PF_TOOLCHAIN   — project:profile toolchain-образа (опционально)
#   PF_DEPS        — зависимости project:profile (через пробелы, опционально)
#
# Опциональные (в Makefile проекта):
#   _EXTRA_BUILD_ARGS   — дополнительные --build-arg
#   _EXTRA_SRC_FILES    — дополнительные файлы для скачивания
#   _EXTRA_CLEAN_FILES  — дополнительные файлы для удаления при clean
#   _HELP_EXTRA         — дополнительные строки для help (shell-команды)
# =============================================================================

# --- Стандартные пути артефактов ---
ARTIFACTS_SRC    ?= artifacts/src
ARTIFACTS_DEPS   ?= artifacts/deps
ARTIFACTS_BUILD  ?= artifacts/build
ARTIFACTS_IMAGES ?= artifacts/images

# --- Профили ---
include ../mk/profiles.mk

# --- Backend (docker/buildah) ---
include ../mk/backend.mk

# --- Deps check macro ---
include ../mk/deps.mk

# =============================================================================
# Хелперы для парсинга PF_DEPS
# Формат: project:profile_id [project:profile_id ...]
# Пример: PF_DEPS = zlib:1.3.1-r1 openssl:1.1.1w-r1
# =============================================================================

# Извлечь имя проекта из dep spec
_dep_prj = $(word 1,$(subst :, ,$(1)))
# Извлечь profile ID из dep spec
_dep_pid = $(word 2,$(subst :, ,$(1)))
# Извлечь чистую версию (strip -rN suffix)
_dep_ver = $(shell echo '$(call _dep_pid,$(1))' | sed 's/-r[0-9]*$$//')
# Uppercase имя проекта (a-z → A-Z, - → _)
_dep_uc = $(shell echo '$(call _dep_prj,$(1))' | tr 'a-z-' 'A-Z_')

# =============================================================================
# Обработка PF_DEPS
# =============================================================================

# Инициализация одной зависимости:
# - UC(project)_VERSION = clean version
# - dep file path → _ALL_DEP_FILES
# - --build-arg → _DEP_BUILD_ARGS
# $(1) = full dep spec (e.g., zlib:1.3.1-r1)
define _init_dep
$(call _dep_uc,$(1))_VERSION := $(call _dep_ver,$(1))
_ALL_DEP_FILES += $$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz
_DEP_BUILD_ARGS += --build-arg $(call _dep_uc,$(1))_VERSION=$(call _dep_ver,$(1))
endef

# Генерация правила извлечения зависимости из образа
# $(1) = full dep spec (e.g., zlib:1.3.1-r1)
define _gen_dep_rule
$$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz:
	@$$(_INSPECT) $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build > /dev/null 2>&1 || \
	  (echo "Error: image $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build not found"; \
	   echo "Build first: make -C ../$(call _dep_prj,$(1)) image $(call _dep_pid,$(1))"; exit 1)
	mkdir -p $$(ARTIFACTS_DEPS)
	@$$(call _extract,$(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build,$$@)
endef

ifdef PF_DEPS
$(foreach dep,$(PF_DEPS),$(eval $(call _init_dep,$(dep))))
$(foreach dep,$(PF_DEPS),$(eval $(call _gen_dep_rule,$(dep))))
endif

_ALL_DEP_FILES := $(strip $(_ALL_DEP_FILES))

# --- Все исходники для download ---
_SRC_FILES = $(SRC_FILE) $(_EXTRA_SRC_FILES)

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

_BUILD_ARGS = \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    --build-arg $(_UC_PROJECT)_VERSION=$(PF_VERSION) \
    $(_DEP_BUILD_ARGS) \
    $(_EXTRA_BUILD_ARGS)

# PF_TOOLCHAIN → --build-arg TOOLCHAIN_IMAGE
ifdef PF_TOOLCHAIN
_EXTRA_BUILD_ARGS += --build-arg TOOLCHAIN_IMAGE=$(call _dep_prj,$(PF_TOOLCHAIN)):$(call _dep_pid,$(PF_TOOLCHAIN))-build
endif

_TAR_NAME = $(PROJECT)-$(V)-build.tar

# --- Валидация ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите версию (например, make docker/image <version>)"; \
    echo "Поддерживаемые версии: $(VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi; \
    if [ -z "$(PF_DOCKERFILE)" ]; then \
    echo "Ошибка: PF_DOCKERFILE не определён в profiles/$(V).mk"; exit 1; fi

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

# =============================================================================
# Targets
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean
.PHONY: $(VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  <version>         Скачать исходники $(PROJECT) (требует интернет)"
	@echo "  deps      <version>         Извлечь зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     <version>         Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     <version>         Архивировать артефакты в artifacts/build/"
	@echo "  test      <version>         Проверить артефакты"
	@echo "  shell     <version>         Shell в образе"
	@echo "  clean     [version]         Удалить образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(VERSIONS)"
ifdef PF_TOOLCHAIN
	@echo ""
	@echo "  Toolchain: $(PF_TOOLCHAIN)"
endif
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),\
	  printf '    %s → artifacts/deps/%s-%s.tar.gz\n' \
	    '$(dep)' '$(call _dep_prj,$(dep))' '$(call _dep_ver,$(dep))';)
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
	@echo "    make docker/image $(firstword $(VERSIONS))"
	@echo "    make docker/test  $(firstword $(VERSIONS))"
	@echo "    make docker/image $(firstword $(VERSIONS)) FORCE=1"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(_SRC_FILES)

# --- Извлечение бинарных зависимостей ---
ifdef PF_DEPS
deps:
	$(call check_version)
	$(if $(_ALL_DEP_FILES),@$(MAKE) $(_ALL_DEP_FILES))
else
deps:
	@:
endif

# --- Сборка образа ---
image:
	$(call check_version)
	@$(MAKE) $(_SRC_FILES)
	$(if $(_ALL_DEP_FILES),@$(foreach d,$(_ALL_DEP_FILES),$(call check_dep,$(d))))
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(PF_DOCKERFILE) \
	  -t $(_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

# --- Экспорт артефактов ---
build:
	$(call check_version)
	$(call ensure,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/$(PROJECT)-$(V).tar.gz)

# --- Тестирование ---
test:
	$(call check_version)
	$(call ensure,$(V))
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),$(_TEST_CMD))

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
	  rm -f $(SRC_FILE) $(_EXTRA_SRC_FILES) $(_EXTRA_CLEAN_FILES); \
	else \
	  for v in $(VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS); \
	fi
	$(if $(_ALL_DEP_FILES),@rm -f $(_ALL_DEP_FILES))

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: версия как цель (например, make docker/image 1.1.0)
$(VERSIONS):
	@:

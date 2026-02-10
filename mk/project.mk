# =============================================================================
# mk/project.mk — общее ядро для всех проектов
#
# Подключение: include ../mk/project.mk (последней строкой Makefile проекта)
#
# Обязательные переменные (задать ДО include):
#   PROJECT      — имя проекта (используется для имени образа)
#   BASE_IMAGE   — базовый Docker-образ
#   SRC_FILE     — путь к архиву исходников, e.g. $(ARTIFACTS_SRC)/zlib-$(V).tar.gz
#   _TEST_CMD    — команда тестирования образа
#
# Опциональные:
#   VERSION_VAR         — имя build-arg для версии (по умолчанию: UC(PROJECT)_VERSION)
#   _DEPS               — зависимости: image:alias:version_var (через пробелы)
#   _EXTRA_BUILD_ARGS   — дополнительные --build-arg
#   _EXTRA_SRC_FILES    — дополнительные файлы для скачивания
#   _EXTRA_CLEAN_FILES  — дополнительные файлы для удаления при clean
#   _HELP_EXTRA         — дополнительные строки для help (shell-команды)
#
# Также проект ДОЛЖЕН определить pattern rule для скачивания SRC_FILE.
# =============================================================================

# --- Стандартные пути артефактов ---
ARTIFACTS_SRC    ?= artifacts/src
ARTIFACTS_DEPS   ?= artifacts/deps
ARTIFACTS_BUILD  ?= artifacts/build
ARTIFACTS_IMAGES ?= artifacts/images

# --- Версии ---
include ../mk/versions.mk

# --- Авторазрешение транзитивных версий зависимостей ---
include ../mk/resolve.mk

# --- Backend (docker/buildah) ---
include ../mk/backend.mk

# --- Uppercase проекта (для VERSION_VAR по умолчанию) ---
_UC_PROJECT := $(shell echo '$(PROJECT)' | tr 'a-z-' 'A-Z_')
VERSION_VAR ?= $(_UC_PROJECT)_VERSION

# =============================================================================
# Обработка зависимостей
# Формат _DEPS: image:alias:version_var [image:alias:version_var ...]
# Пример: _DEPS = zlib:ZL:ZLIB_VERSION openssl:OL:OPENSSL_VERSION
# =============================================================================

ifdef _DEPS
include ../mk/deps.mk
endif

# Макрос инициализации одной зависимости
# $(1)=image_prefix  $(2)=alias  $(3)=version_var
define _init_dep
$(2) ?= $$($(3))
_DEP_$(2) = $$(if $$($(2)),$$(ARTIFACTS_DEPS)/$(1)-$$($(2)).tar.gz)
_ALL_DEPS += $$(_DEP_$(2))
_DEP_BUILD_ARGS += $$(if $$($(2)),--build-arg $(3)=$$($(2)))
endef

$(foreach dep,$(_DEPS),$(eval $(call _init_dep,$(word 1,$(subst :, ,$(dep))),$(word 2,$(subst :, ,$(dep))),$(word 3,$(subst :, ,$(dep))))))

$(foreach dep,$(_DEPS),$(eval $(call dep_rule,$(word 1,$(subst :, ,$(dep))),$(word 1,$(subst :, ,$(dep))))))

_ALL_DEPS := $(strip $(_ALL_DEPS))

# --- Все исходники для download ---
_SRC_FILES = $(SRC_FILE) $(_EXTRA_SRC_FILES)

# =============================================================================
# Вычисляемые переменные
# =============================================================================

image_name = $(PROJECT):$(1)-build

_IMAGE  = $(call image_name,$(V))
_LABELS = \
    --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-build \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)

_BUILD_ARGS = \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    --build-arg $(VERSION_VAR)=$(V) \
    $(_DEP_BUILD_ARGS) \
    $(_EXTRA_BUILD_ARGS)

_TAR_NAME = $(PROJECT)-$(V)-build.tar

# --- Валидация и ensure ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите версию (например, make docker/image <version>)"; \
    echo "Поддерживаемые версии: $(VERSIONS)"; exit 1; fi

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

# =============================================================================
# Targets
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean
ifdef _DEPS
.PHONY: deps
endif
.PHONY: $(VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  <version>         Скачать исходники $(PROJECT) (требует интернет)"
ifdef _DEPS
	@echo "  deps      <version>         Извлечь зависимости из Docker-образов в artifacts/deps/"
endif
	@echo "  image     <version>         Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     <version>         Архивировать артефакты в artifacts/build/"
	@echo "  test      <version>         Проверить артефакты"
	@echo "  shell     <version>         Shell в образе"
	@echo "  clean     [version]         Удалить образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(VERSIONS)"
ifdef _DEPS
	@echo ""
	@echo "  Зависимости (deps):"
	@$(foreach dep,$(_DEPS),\
	  printf '    %s:<%s>-build → artifacts/deps/\n' \
	    '$(word 1,$(subst :, ,$(dep)))' '$(word 2,$(subst :, ,$(dep)))';)
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
ifdef _DEPS
deps:
	$(call check_version)
	$(if $(_ALL_DEPS),@$(MAKE) $(_ALL_DEPS))
endif

# --- Сборка образа ---
image:
	$(call check_version)
	@$(MAKE) $(_SRC_FILES)
	$(if $(_ALL_DEPS),@$(foreach d,$(_ALL_DEPS),$(call check_dep,$(d))))
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_DOCKERFILE) \
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
	$(foreach d,$(_ALL_DEPS),@rm -f $(d)
	)

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

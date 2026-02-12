-include config.local.mk
-include config.mk

PROJECT       := buildah
BASE_IMAGE    := astra-linux:2.12
include ../mk/profiles.mk
BUILDAH_VERSIONS := $(VERSIONS)
T ?= build

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

BUILDAH_REPO        := $(GITHUB_URL)/containers/buildah.git
BUILDAH_ARCHIVE_URL  = $(BUILDAH_REPO:.git=)/archive/refs/tags

include ../mk/backend.mk
include ../mk/deps.mk

# --- Хелперы для PF_ ---
_dep_prj = $(word 1,$(subst :, ,$(1)))
_dep_pid = $(word 2,$(subst :, ,$(1)))
_dep_ver = $(shell echo '$(call _dep_pid,$(1))' | sed 's/-r[0-9]*$$//')
_dep_uc  = $(shell echo '$(call _dep_prj,$(1))' | tr 'a-z-' 'A-Z_')

# --- Обработка PF_DEPS и PF_TOOLCHAIN: генерация dep files и build-args ---
define _init_dep
$(call _dep_uc,$(1))_VERSION := $(call _dep_ver,$(1))
_ALL_DEP_FILES += $$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz
_DEP_BUILD_ARGS += --build-arg $(call _dep_uc,$(1))_VERSION=$(call _dep_ver,$(1))
endef

define _gen_dep_rule
$$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz:
	@$$(_INSPECT) $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build > /dev/null 2>&1 || \
	  (echo "Error: image $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build not found"; exit 1)
	mkdir -p $$(ARTIFACTS_DEPS)
	@$$(call _extract,$(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build,$$@)
endef

# PF_TOOLCHAIN (golang) обрабатывается как dep — извлекается tar.gz
ifdef PF_TOOLCHAIN
$(eval $(call _init_dep,$(PF_TOOLCHAIN)))
$(eval $(call _gen_dep_rule,$(PF_TOOLCHAIN)))
endif

ifdef PF_DEPS
$(foreach dep,$(PF_DEPS),$(eval $(call _init_dep,$(dep))))
$(foreach dep,$(PF_DEPS),$(eval $(call _gen_dep_rule,$(dep))))
endif
_ALL_DEP_FILES := $(strip $(_ALL_DEP_FILES))

# --- Имена образов ---
image_name   = $(PROJECT):$(1)-build
runtime_name = $(PROJECT)-astra:$(1)-runtime

# --- Вычисляемые переменные ---
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),Dockerfile.astra-runtime,$(PF_DOCKERFILE))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILDAH_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILDAH_VERSION=$(PF_VERSION) $(_DEP_BUILD_ARGS))

_LABELS     = --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-$(T) \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)
_TAR_NAME   = $(if $(filter runtime,$(T)),$(PROJECT)-astra-$(V)-runtime,$(PROJECT)-$(V)-build).tar
_TEST_CMD   = $(if $(filter runtime,$(T)),buildah version,sh -c '/out/usr/bin/buildah version && (ldd /out/usr/bin/buildah 2>&1 || echo "static: ok")')

# --- Debian ---
DEBIAN_BASE_IMAGE    := debian:bookworm-slim
DEBIAN_CODENAME      := bookworm
DEBIAN_RUNTIME_IMAGE := buildah-debian:$(DEBIAN_CODENAME)-runtime

DEBIAN_LABELS := \
	--label org.opencontainers.image.title=buildah-debian \
	--label org.opencontainers.image.version=$(DEBIAN_CODENAME)-runtime \
	--label org.opencontainers.image.base.name=$(DEBIAN_BASE_IMAGE)

# --- Валидация ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию"; echo "Поддерживаемые версии: $(BUILDAH_VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/buildah-$(PF_VERSION).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/buildah-$(PF_VERSION).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) image V=$(1) T=runtime
ensure_debian  = @$(call _ensure_check,$(DEBIAN_RUNTIME_IMAGE)) $(MAKE) image-debian

.DEFAULT_GOAL := help

.PHONY: help download deps image image-astra \
        build test shell clean \
        image-debian test-debian shell-debian clean-debian \
        $(BUILDAH_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Astra Linux (сборка из исходников):"
	@echo "  download  <version>          Скачать исходники buildah (требует интернет)"
	@echo "  deps      <version>          Извлечь бинарные зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     <version> [T=type] Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     <version>          Архивировать артефакты в artifacts/build/"
	@echo "  test      <version> [T=type] Проверить buildah version"
	@echo "  shell     <version> [T=type] Shell в образе"
	@echo "  clean     <version>          Удалить образы и артефакты версии"
	@echo ""
	@echo "  Поддерживаемые версии: $(BUILDAH_VERSIONS)"
	@echo "  Типы образов (T): build (по умолчанию), runtime"
ifdef PF_TOOLCHAIN
	@echo ""
	@echo "  Toolchain: $(PF_TOOLCHAIN)"
endif
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/download 1.38.0-r1"
	@echo "    make docker/deps     1.38.0-r1"
	@echo "    make docker/image    1.38.0-r1 T=build"
	@echo "    make docker/image    1.38.0-r1 T=runtime"
	@echo ""
	@echo "Debian (установка из пакетов):"
	@echo "  image-debian                 Собрать образ и экспортировать в artifacts/images/"
	@echo "  test-debian                  Проверить buildah version"
	@echo "  shell-debian                 Shell в runtime-образе"
	@echo "  clean-debian                 Удалить образы и артефакты"
	@echo ""
	@echo "Общее:"
	@echo "  clean                        Удалить все образы и артефакты"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/buildah-$(PF_VERSION).tar.gz

$(ARTIFACTS_SRC)/buildah-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(BUILDAH_ARCHIVE_URL)/v$*.tar.gz

# --- Извлечение бинарных зависимостей ---
deps:
	$(call check_version)
	$(if $(_ALL_DEP_FILES),@$(MAKE) $(_ALL_DEP_FILES))

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

# --- Backwards-compat alias ---
image-astra:
	@$(MAKE) image V=$(V) T=$(T)

image:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_src_file))
	$(if $(_ALL_DEP_FILES),@$(foreach d,$(_ALL_DEP_FILES),$(if $(filter build,$(T)),$(call check_dep,$(d)))))
	$(if $(filter runtime,$(T)),$(call ensure,$(V)))
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_DOCKERFILE) \
	  -t $(_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

build:
	$(call check_version)
	$(call ensure,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/buildah-$(PF_VERSION).tar.gz)

test:
	$(call check_version)
	$(if $(filter runtime,$(T)),$(call ensure_runtime,$(V)),$(call ensure,$(V)))
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),$(_TEST_CMD))

shell:
	$(call check_version)
	$(if $(filter runtime,$(T)),$(call ensure_runtime,$(V)),$(call ensure,$(V)))
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(call runtime_name,$(V)) 2>/dev/null || true; \
	  docker rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call runtime_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/buildah-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/buildah-astra-$(V)-runtime.tar; \
	  rm -f $(ARTIFACTS_BUILD)/buildah-$(PF_VERSION).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/buildah-$(PF_VERSION).tar.gz; \
	else \
	  for v in $(BUILDAH_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  $(MAKE) clean-debian; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS); \
	fi
	$(foreach d,$(_ALL_DEP_FILES),@rm -f $(d)
	)

# --- Debian ---
image-debian:
	$(_BUILD) \
	  --build-arg BASE_IMAGE=$(DEBIAN_BASE_IMAGE) \
	  $(DEBIAN_LABELS) \
	  -f Dockerfile.debian \
	  -t $(DEBIAN_RUNTIME_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(DEBIAN_RUNTIME_IMAGE),$(ARTIFACTS_IMAGES)/buildah-debian-$(DEBIAN_CODENAME)-runtime.tar)

test-debian:
	$(call ensure_debian)
	@echo "=== $(DEBIAN_RUNTIME_IMAGE) ==="
	@$(call _run,$(DEBIAN_RUNTIME_IMAGE),buildah version)

shell-debian:
	$(call ensure_debian)
	@$(call _shell,$(DEBIAN_RUNTIME_IMAGE))

clean-debian:
	@docker rmi $(DEBIAN_RUNTIME_IMAGE) 2>/dev/null || true
	@buildah rmi $(DEBIAN_RUNTIME_IMAGE) 2>/dev/null || true
	@rm -f $(ARTIFACTS_IMAGES)/buildah-debian-$(DEBIAN_CODENAME)-runtime.tar

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V)) T=$(T)

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V)) T=$(T)

# Catch-all: версия как цель (например, make docker/image 1.38.0-r1)
$(BUILDAH_VERSIONS):
	@:

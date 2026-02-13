-include config.local.mk
-include config.mk

PROJECT       := buildah
BASE_IMAGE    := astra-linux:2.12
include ../mk/profiles.mk
BUILDAH_VERSIONS := $(VERSIONS)
T ?= build

include ../mk/backend.mk

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

# --- Рендеринг Dockerfile ---
_RENDER = ../mk/render-dockerfile.sh $(PROJECT) $(_DOCKERFILE)
_RENDERED_FILE = .rendered.Dockerfile
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
    if [ ! -f profiles/$(V).mk ]; then echo "Ошибка: profiles/$(V).mk не найден"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) build V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) build V=$(1) T=runtime
ensure_debian  = @$(call _ensure_check,$(DEBIAN_RUNTIME_IMAGE)) $(MAKE) build-debian

.DEFAULT_GOAL := help

.PHONY: help show-urls download render build build-astra \
        export test shell clean \
        build-debian test-debian shell-debian clean-debian \
        $(BUILDAH_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Astra Linux (сборка из исходников):"
	@echo "  show-urls <profile>           Показать URL-ы исходников (для оркестрации)"
	@echo "  download  <profile>           Скачать исходники buildah (требует интернет)"
	@echo "  build     <profile> [T=type]  Собрать образ и экспортировать в artifacts/images/"
	@echo "  export    <profile>           Архивировать артефакты в artifacts/build/"
	@echo "  test      <profile> [T=type]  Проверить buildah version"
	@echo "  shell     <profile> [T=type]  Shell в образе"
	@echo "  clean     <profile>           Удалить образы и артефакты версии"
	@echo ""
	@echo "  Поддерживаемые версии: $(BUILDAH_VERSIONS)"
	@echo "  Типы образов (T): build (по умолчанию), runtime"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/download 1.38.0"
	@echo "    make docker/build    1.38.0 T=build"
	@echo "    make docker/build    1.38.0 T=runtime"
	@echo ""
	@echo "Debian (установка из пакетов):"
	@echo "  build-debian                 Собрать образ и экспортировать в artifacts/images/"
	@echo "  test-debian                  Проверить buildah version"
	@echo "  shell-debian                 Shell в runtime-образе"
	@echo "  clean-debian                 Удалить образы и артефакты"
	@echo ""
	@echo "Общее:"
	@echo "  clean                        Удалить все образы и артефакты"

show-urls:
	$(call check_version)
	@$(MAKE) --no-print-directory _list_urls V=$(V) DEST=$(PROJECT)/$(ARTIFACTS_SRC) | sort -u

# --- Скачивание исходников (рекурсивно через _download_to) ---
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

# --- Рендеринг ---
render:
	$(call check_version)
	@$(_RENDER) > $(_RENDERED_FILE)
	@cat $(_RENDERED_FILE)

# --- Backwards-compat alias ---
build-astra:
	@$(MAKE) build V=$(V) T=$(T)

build:
	$(call check_version)
	$(if $(filter build,$(T)),@$(MAKE) --no-print-directory _check_src V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC))
	$(if $(filter runtime,$(T)),$(call ensure,$(V)))
	@$(_RENDER) > $(_RENDERED_FILE)
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_RENDERED_FILE) \
	  -t $(_IMAGE) ..
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

export:
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
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# --- Debian ---
build-debian:
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

# Catch-all: версия как цель (например, make docker/build 1.38.0)
$(BUILDAH_VERSIONS):
	@:

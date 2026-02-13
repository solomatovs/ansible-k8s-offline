-include config.local.mk
-include config.mk

GO_PROXY_URL  ?= $(GOPROXY_URL)
PROJECT       := golang
BASE_IMAGE    := astra-linux:2.12

# Цепочка bootstrap: 1.4 → 1.17.13 → 1.20.6 → 1.22.6 → 1.24.5
include ../mk/profiles.mk
GO_VERSIONS := $(VERSIONS)
T ?= build

include ../mk/backend.mk

# --- Имена образов ---
image_name   = $(PROJECT):$(1)-build
runtime_name = $(PROJECT)-astra:$(1)-runtime

# --- Валидация ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию"; echo "Поддерживаемые версии: $(GO_VERSIONS)"; exit 1; fi; \
    if [ ! -f profiles/$(V).mk ]; then echo "Ошибка: profiles/$(V).mk не найден"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi
# --- Ensure ---
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) build V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) build V=$(1) T=runtime

# --- Вычисляемые переменные ---
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),Dockerfile.runtime,$(PF_DOCKERFILE))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg GO_PROXY_URL=$(GO_PROXY_URL) --build-arg GOLANG_VERSION=$(PF_VERSION) $(_DEP_BUILD_ARGS))

_LABELS     = --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-$(T) \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)
_TAR_NAME   = $(if $(filter runtime,$(T)),$(PROJECT)-astra-$(V)-runtime,$(PROJECT)-$(V)-build).tar

# --- Рендеринг Dockerfile ---
_RENDER = ../mk/render-dockerfile.sh $(PROJECT) $(_DOCKERFILE)
_RENDERED_FILE = .rendered.Dockerfile

_BUILD_TEST_CMD = $(if $(filter Dockerfile.bootstrap,$(PF_DOCKERFILE)),sh -c 'GOROOT=/out/usr/local/go /out/usr/local/go/bin/go version',/out/usr/local/go/bin/go version)
_TEST_CMD       = $(if $(filter runtime,$(T)),go version,$(_BUILD_TEST_CMD))

.DEFAULT_GOAL := help

.PHONY: help show-urls download render build export test shell clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  show-urls <profile>          Показать URL-ы исходников (для оркестрации)"
	@echo "  download  <profile>          Скачать исходники Go (требует интернет)"
	@echo "  build     <profile> [T=type] Собрать образ и экспортировать в artifacts/images/"
	@echo "  export    <profile>          Архивировать скомпилированный Go в artifacts/build/"
	@echo "  test      <profile> [T=type] Проверить go version"
	@echo "  shell     <profile> [T=type] Shell в образе"
	@echo "  clean     <profile>          Удалить образы и артефакты версии"
	@echo "  clean                        Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(GO_VERSIONS)"
	@echo "  Типы образов (T): build (по умолчанию), runtime"
	@echo ""
	@echo "  Цепочка bootstrap: 1.4 → 1.17.13 → 1.20.6 → 1.22.6 → 1.24.5"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/build  1.24.5"
	@echo "    make docker/build  1.24.5 T=runtime"
	@echo "    make docker/test   1.22.6"
	@echo "    make docker/export 1.22.6"
	@echo "    make docker/clean  1.22.6"

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

render:
	$(call check_version)
	@$(_RENDER) > $(_RENDERED_FILE)
	@cat $(_RENDERED_FILE)

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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/golang-$(PF_VERSION).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-astra-$(V)-runtime.tar; \
	  rm -f $(ARTIFACTS_BUILD)/golang-$(PF_VERSION).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/golang-$(PF_VERSION).tar.gz; \
	else \
	  for v in $(GO_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V)) T=$(T)

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V)) T=$(T)

# Catch-all: версия как цель (например, make docker/build 1.22.6)
$(GO_VERSIONS):
	@:

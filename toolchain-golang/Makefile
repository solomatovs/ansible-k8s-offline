# =============================================================================
# toolchain-golang — унифицированный базовый образ для Go-проектов
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := toolchain-golang
BASE_IMAGE := astra-linux:2.12

# --- Профили ---
include ../mk/profiles.mk

# --- Backend (docker/buildah) ---
include ../mk/backend.mk

# --- Имя образа ---
image_name = $(PROJECT):$(1)-build
_IMAGE     = $(call image_name,$(V))

# --- Build args ---
_BUILD_ARGS = \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    $(_DEP_BUILD_ARGS)

_LABELS = \
    --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-build \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE) \
    --label "org.opencontainers.image.description=$(PF_DEPS)"

# --- Рендеринг Dockerfile ---
_RENDER = ../mk/render-dockerfile.sh $(PROJECT) $(PF_DOCKERFILE)
_RENDERED_FILE = .rendered.Dockerfile

# --- Валидация ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите версию (например, make docker/build $(firstword $(VERSIONS)))"; \
    echo "Поддерживаемые версии: $(VERSIONS)"; exit 1; fi; \
    if [ ! -f profiles/$(V).mk ]; then \
    echo "Ошибка: profiles/$(V).mk не найден"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi

check_image = @$(_INSPECT) $(1) > /dev/null 2>&1 || \
	{ echo "Ошибка: образ $(1) не найден" >&2; \
	  echo "Сначала соберите: make -C ../$(2) docker/build $(3)" >&2; exit 1; }

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) build V=$(1)

# =============================================================================
# Targets
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help show-urls download render build test shell clean
.PHONY: $(VERSIONS)

help:
	@echo "Usage: make docker/<target> <profile>   (на хосте, через Docker)"
	@echo "       make buildah/<target> <profile>  (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  build   <profile>   Собрать toolchain-образ"
	@echo "  test    <profile>   Проверить go version и инструменты"
	@echo "  shell   <profile>   Shell в образе"
	@echo "  clean   [profile]   Удалить образы"
	@echo ""
	@echo "  Поддерживаемые версии: $(VERSIONS)"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/build $(firstword $(VERSIONS))"
	@echo "    make docker/test  $(firstword $(VERSIONS))"

show-urls:
	$(call check_version)
	@$(MAKE) --no-print-directory _list_urls V=$(V) DEST=$(PROJECT)/$(ARTIFACTS_SRC) | sort -u

# --- Скачивание исходников (рекурсивно через _download_to) ---
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)

render:
	$(call check_version)
	@$(_RENDER) > $(_RENDERED_FILE)
	@cat $(_RENDERED_FILE)

build:
	$(call check_version)
	@$(MAKE) --no-print-directory _check_src V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
	@$(_RENDER) > $(_RENDERED_FILE)
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_RENDERED_FILE) \
	  -t $(_IMAGE) ..
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar)

test:
	$(call check_version)
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),sh -c '\
		echo "--- go ---" && go version && \
		echo "--- env ---" && \
		echo "GOROOT=$$GOROOT" && echo "GOPATH=$$GOPATH" && \
		echo "--- gcc ---" && gcc --version | head -1 && \
		echo "--- tools ---" && \
		make --version | head -1 && \
		pkg-config --version && \
		git --version && \
		echo "toolchain-golang $(V): ok"')

shell:
	$(call check_version)
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(_IMAGE) 2>/dev/null || true; \
	  buildah rmi $(_IMAGE) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar; \
	else \
	  for v in $(VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_IMAGES); \
	fi

# =============================================================================
# Namespace shortcuts
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

$(VERSIONS):
	@:

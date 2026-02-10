-include config.local.mk
-include config.mk

GO_REPO       := $(GITHUB_URL)/golang/go.git
GO_PROXY_URL  ?= $(GOPROXY_URL)
IMAGE_NAME    := golang
BASE_IMAGE    := astra-linux:2.12

# Цепочка bootstrap: 1.4 → 1.17.13 → 1.20.6 → 1.22.6 → 1.24.5
# Каждая версия собирается предыдущей. 1.4 — начальный bootstrap (без deps).
EXTRA_VERSIONS := 1.4
include ../mk/versions.mk
GO_VERSIONS := $(VERSIONS)
T ?= runtime

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

GO_ARCHIVE_URL = $(GO_REPO:.git=)/archive/refs/tags

BUILD_ARGS_COMMON := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GO_PROXY_URL=$(GO_PROXY_URL)

include ../mk/backend.mk

# --- Имена образов ---
image_name   = $(IMAGE_NAME):$(1)-build
runtime_name = $(IMAGE_NAME)-astra:$(1)-runtime

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=$(1) \
	--label org.opencontainers.image.version=$(2)-$(3) \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Валидация (внешние зависимости — ошибка если нет) ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 1.22.6)"; echo "Поддерживаемые версии: $(GO_VERSIONS)"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/golang-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/golang-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)

# --- Ensure (внутренние зависимости — автосборка если нет) ---
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) image V=$(1) T=runtime

# --- Вычисляемые переменные для текущих V и T ---
_BOOTSTRAP  = $(BOOTSTRAP_VERSION)
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),\
  $(or $(DOCKERFILE_RUNTIME),Dockerfile.runtime),\
  $(if $(_BOOTSTRAP),\
    $(or $(DOCKERFILE_BUILD),Dockerfile),\
    $(or $(DOCKERFILE_BOOTSTRAP),Dockerfile.bootstrap)))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  $(BUILD_ARGS_COMMON) --build-arg GO_VERSION=$(V)$(if $(_BOOTSTRAP), --build-arg BOOTSTRAP_IMAGE=$(call image_name,$(_BOOTSTRAP))))

_LABELS     = $(call labels,$(if $(filter runtime,$(T)),$(IMAGE_NAME)-astra,$(IMAGE_NAME)),$(V),$(T))
_TAR_NAME   = $(if $(filter runtime,$(T)),$(IMAGE_NAME)-astra,$(IMAGE_NAME))-$(V)-$(T).tar

_BUILD_TEST_CMD = $(if $(filter 1.4,$(V)),sh -c 'GOROOT=/out/usr/local/go /out/usr/local/go/bin/go version',/out/usr/local/go/bin/go version)
_TEST_CMD       = $(if $(filter runtime,$(T)),go version,$(_BUILD_TEST_CMD))

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z             Скачать исходники Go (требует интернет)"
	@echo "  image     X.Y.Z [T=type]    Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z             Архивировать скомпилированный Go в artifacts/build/"
	@echo "  test      X.Y.Z [T=type]    Проверить go version"
	@echo "  shell     X.Y.Z [T=type]    Shell в образе"
	@echo "  clean     X.Y.Z             Удалить образы и артефакты версии"
	@echo "  clean                       Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(GO_VERSIONS)"
	@echo "  Типы образов (T): runtime (по умолчанию), build"
	@echo ""
	@echo "  Цепочка bootstrap: 1.4 → 1.17.13 → 1.20.6 → 1.22.6 → 1.24.5"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 1.24.5"
	@echo "    make docker/image 1.24.5 T=runtime"
	@echo "    make docker/test  1.22.6"
	@echo "    make docker/build 1.22.6"
	@echo "    make docker/clean 1.22.6"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/golang-$(V).tar.gz

$(ARTIFACTS_SRC)/golang-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GO_ARCHIVE_URL)/go$*.tar.gz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_src_file))
	$(if $(filter runtime,$(T)),$(call ensure,$(V)))
	$(if $(and $(filter build,$(T)),$(_BOOTSTRAP)),$(call ensure,$(_BOOTSTRAP)))
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/golang-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/$(IMAGE_NAME)-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/$(IMAGE_NAME)-astra-$(V)-runtime.tar; \
	  rm -f $(ARTIFACTS_BUILD)/golang-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/golang-$(V).tar.gz; \
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

# Catch-all: версия как цель (например, make docker/image 1.22.6)
$(GO_VERSIONS):
	@:

-include config.local.mk
-include config.mk

GO_REPO       := $(GITHUB_URL)/golang/go.git
GO_PROXY_URL  ?= $(GOPROXY_URL)
PROJECT       := golang
BASE_IMAGE    := astra-linux:2.12

# Цепочка bootstrap: 1.4 → 1.17.13 → 1.20.6 → 1.22.6 → 1.24.5
include ../mk/profiles.mk
GO_VERSIONS := $(VERSIONS)
T ?= build

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

GO_ARCHIVE_URL = $(GO_REPO:.git=)/archive/refs/tags

include ../mk/backend.mk

# --- Хелперы для PF_TOOLCHAIN ---
_dep_prj = $(word 1,$(subst :, ,$(1)))
_dep_pid = $(word 2,$(subst :, ,$(1)))

# --- Имена образов ---
image_name   = $(PROJECT):$(1)-build
runtime_name = $(PROJECT)-astra:$(1)-runtime

# --- Валидация ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию"; echo "Поддерживаемые версии: $(GO_VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/golang-$(PF_VERSION).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/golang-$(PF_VERSION).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)

# --- Ensure ---
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) image V=$(1) T=runtime

# --- Вычисляемые переменные из PF_ ---
_TOOLCHAIN_IMAGE = $(if $(PF_TOOLCHAIN),$(call _dep_prj,$(PF_TOOLCHAIN)):$(call _dep_pid,$(PF_TOOLCHAIN))-build)
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),Dockerfile.runtime,$(PF_DOCKERFILE))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg GO_PROXY_URL=$(GO_PROXY_URL) --build-arg GOLANG_VERSION=$(PF_VERSION)$(if $(_TOOLCHAIN_IMAGE), --build-arg TOOLCHAIN_IMAGE=$(_TOOLCHAIN_IMAGE)))

_LABELS     = --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-$(T) \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)
_TAR_NAME   = $(if $(filter runtime,$(T)),$(PROJECT)-astra-$(V)-runtime,$(PROJECT)-$(V)-build).tar

_BUILD_TEST_CMD = $(if $(filter Dockerfile.bootstrap,$(PF_DOCKERFILE)),sh -c 'GOROOT=/out/usr/local/go /out/usr/local/go/bin/go version',/out/usr/local/go/bin/go version)
_TEST_CMD       = $(if $(filter runtime,$(T)),go version,$(_BUILD_TEST_CMD))

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean

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
ifdef PF_TOOLCHAIN
	@echo "  Toolchain: $(PF_TOOLCHAIN)"
endif
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
	@$(MAKE) $(ARTIFACTS_SRC)/golang-$(PF_VERSION).tar.gz

$(ARTIFACTS_SRC)/golang-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GO_ARCHIVE_URL)/go$*.tar.gz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

deps:
	@:

image:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_src_file))
	$(if $(filter runtime,$(T)),$(call ensure,$(V)))
	$(if $(and $(filter build,$(T)),$(_TOOLCHAIN_IMAGE)),@$(_INSPECT) $(_TOOLCHAIN_IMAGE) > /dev/null 2>&1 || \
	  { echo "Ошибка: образ $(_TOOLCHAIN_IMAGE) не найден" >&2; exit 1; })
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
	  rm -f $(ARTIFACTS_IMAGES)/$(IMAGE_NAME)-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/$(IMAGE_NAME)-astra-$(V)-runtime.tar; \
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

# Catch-all: версия как цель (например, make docker/image 1.22.6)
$(GO_VERSIONS):
	@:

-include config.local.mk
-include config.mk

BUILDAH_REPO     := $(GITHUB_URL)/containers/buildah.git
BUILDAH_VERSIONS := 1.38.0 1.42.0 1.43.0

# Версия из командной строки: make docker/test-astra 1.38.0
_VERSION_ARGS := $(filter $(BUILDAH_VERSIONS),$(MAKECMDGOALS))
V := $(or $(V),$(firstword $(_VERSION_ARGS)))
T ?= runtime

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

BUILDAH_ARCHIVE_URL = $(BUILDAH_REPO:.git=)/archive/refs/tags

# =============================================================================
# Backend: buildah (по умолчанию) или docker
# =============================================================================
BACKEND ?= buildah

ifeq ($(BACKEND),docker)
  _BUILD   = docker build
  _RMI     = docker rmi
  _INSPECT = docker inspect
  _save    = docker save -o $(2) $(1)
  _run     = docker run --rm $(1) $(2)
  _shell   = docker run --rm -it $(1) /bin/bash
  _extract = id=$$(docker create $(1) true) && docker cp "$$id":/out/. - | gzip > $(2) && docker rm "$$id" > /dev/null
else
  _BUILD   = buildah bud
  _RMI     = buildah rmi
  _INSPECT = buildah inspect
  _save    = rm -f $(2) && buildah push $(1) docker-archive:$(2):$(1)
  _run     = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- $(2) && buildah rm "$$ctr" > /dev/null
  _shell   = ctr=$$(buildah from $(1)) && buildah run --tty "$$ctr" -- /bin/bash; buildah rm "$$ctr" > /dev/null 2>&1 || true
  _extract = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- tar -cf - -C /out . | gzip > $(2) && buildah rm "$$ctr" > /dev/null
endif

# --- Astra Linux ---
ASTRA_BASE_IMAGE := astra-linux:2.12

# Go-компилятор по умолчанию для каждой версии buildah
# Переопределение: make docker/image-astra 1.38.0 G=1.24.5
GO_1.38.0 := 1.22.6
GO_1.42.0 := 1.24.5
GO_1.43.0 := 1.24.5

G ?= $(GO_$(V))

ASTRA_GO_IMAGE = golang-astra:$(G)-build

astra_build_name   = buildah-astra:$(1)-build
astra_runtime_name = buildah-astra:$(1)-runtime

astra_build_args = \
	--build-arg BASE_IMAGE=$(ASTRA_BASE_IMAGE) \
	--build-arg GO_IMAGE=$(ASTRA_GO_IMAGE) \
	--build-arg BUILDAH_VERSION=$(1)

astra_runtime_build_args = \
	--build-arg BASE_IMAGE=$(ASTRA_BASE_IMAGE) \
	--build-arg BUILDAH_IMAGE=$(call astra_build_name,$(1))

astra_labels = \
	--label org.opencontainers.image.title=buildah-astra \
	--label org.opencontainers.image.version=$(1)-$(2) \
	--label org.opencontainers.image.base.name=$(ASTRA_BASE_IMAGE)

# --- Вычисляемые переменные для текущих V и T ---
_ASTRA_IMAGE      = $(if $(filter build,$(T)),$(call astra_build_name,$(V)),$(call astra_runtime_name,$(V)))
_ASTRA_DOCKERFILE = $(if $(filter build,$(T)),Dockerfile.astra,Dockerfile.astra-runtime)
_ASTRA_BUILD_ARGS = $(if $(filter build,$(T)),$(call astra_build_args,$(V)),$(call astra_runtime_build_args,$(V)))
_ASTRA_LABELS     = $(call astra_labels,$(V),$(T))
_ASTRA_TAR_NAME   = buildah-astra-$(V)-$(T).tar
_ASTRA_TEST_CMD   = $(if $(filter build,$(T)),/out/usr/bin/buildah version && (ldd /out/usr/bin/buildah 2>&1 || echo "static: ok"),buildah version)

# --- Debian ---
DEBIAN_BASE_IMAGE    := debian:bookworm-slim
DEBIAN_CODENAME      := bookworm
DEBIAN_RUNTIME_IMAGE := buildah-debian:$(DEBIAN_CODENAME)-runtime

DEBIAN_LABELS := \
	--label org.opencontainers.image.title=buildah-debian \
	--label org.opencontainers.image.version=$(DEBIAN_CODENAME)-runtime \
	--label org.opencontainers.image.base.name=$(DEBIAN_BASE_IMAGE)

# --- Валидация (внешние зависимости — ошибка если нет) ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image-astra 1.38.0)"; echo "Поддерживаемые версии: $(BUILDAH_VERSIONS)"; exit 1; fi
check_go       = @if [ -z "$(G)" ]; then echo "Ошибка: Go-компилятор не задан для версии $(V)"; echo "Добавьте GO_$(V) := X.Y.Z в Makefile или задайте G=X.Y.Z"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/buildah-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/buildah-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)

# --- Ensure (внутренние зависимости — автосборка если нет) ---
ensure_astra         = @$(_INSPECT) $(call astra_build_name,$(1)) > /dev/null 2>&1 || $(MAKE) image-astra V=$(1) T=build
ensure_astra_runtime = @$(_INSPECT) $(call astra_runtime_name,$(1)) > /dev/null 2>&1 || $(MAKE) image-astra V=$(1) T=runtime
ensure_debian        = @$(_INSPECT) $(DEBIAN_RUNTIME_IMAGE) > /dev/null 2>&1 || $(MAKE) image-debian

.DEFAULT_GOAL := help

.PHONY: help download \
        image-astra build-astra test-astra shell-astra clean-astra \
        image-debian test-debian shell-debian clean-debian \
        clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Astra Linux (сборка из исходников):"
	@echo "  download     X.Y.Z                   Скачать исходники buildah (требует интернет)"
	@echo "  image-astra  X.Y.Z [T=type] [G=comp] Собрать образ и экспортировать в artifacts/images/"
	@echo "  build-astra  X.Y.Z [G=comp]          Архивировать артефакты в artifacts/build/"
	@echo "  test-astra   X.Y.Z [T=type]          Проверить buildah version"
	@echo "  shell-astra  X.Y.Z [T=type]          Shell в образе"
	@echo "  clean-astra  X.Y.Z                   Удалить образы и артефакты версии"
	@echo ""
	@echo "  Поддерживаемые версии: $(BUILDAH_VERSIONS)"
	@echo "  Типы образов (T): runtime (по умолчанию), build"
	@echo "  Go-компилятор (G):$(foreach v,$(BUILDAH_VERSIONS), $(v)→$(GO_$(v)))"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image-astra 1.38.0"
	@echo "    make docker/image-astra 1.38.0 T=build"
	@echo "    make docker/image-astra 1.43.0"
	@echo "    make docker/image-astra 1.38.0 G=1.24.5"
	@echo ""
	@echo "Debian (установка из пакетов):"
	@echo "  image-debian                          Собрать образ и экспортировать в artifacts/images/"
	@echo "  test-debian                           Проверить buildah version"
	@echo "  shell-debian                          Shell в runtime-образе"
	@echo "  clean-debian                          Удалить образы и артефакты"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image-debian"
	@echo "    make docker/test-debian"
	@echo ""
	@echo "Общее:"
	@echo "  clean                                 Удалить все образы и артефакты"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/buildah-$(V).tar.gz

$(ARTIFACTS_SRC)/buildah-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(BUILDAH_ARCHIVE_URL)/v$*.tar.gz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

# --- Astra ---
image-astra:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_go))
	$(if $(filter build,$(T)),$(call check_src_file))
	$(if $(filter runtime,$(T)),$(call ensure_astra,$(V)))
	$(_BUILD) \
	  $(_ASTRA_BUILD_ARGS) \
	  $(_ASTRA_LABELS) \
	  -f $(_ASTRA_DOCKERFILE) \
	  -t $(_ASTRA_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_ASTRA_IMAGE),$(ARTIFACTS_IMAGES)/$(_ASTRA_TAR_NAME))

build-astra:
	$(call check_version)
	$(call ensure_astra,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call astra_build_name,$(V)),$(ARTIFACTS_BUILD)/buildah-astra-$(V).tar.gz)

test-astra:
	$(call check_version)
	$(if $(filter runtime,$(T)),$(call ensure_astra_runtime,$(V)),$(call ensure_astra,$(V)))
	@echo "=== $(_ASTRA_IMAGE) ==="
	@$(call _run,$(_ASTRA_IMAGE),sh -c '$(_ASTRA_TEST_CMD)')

shell-astra:
	$(call check_version)
	$(if $(filter runtime,$(T)),$(call ensure_astra_runtime,$(V)),$(call ensure_astra,$(V)))
	@$(call _shell,$(_ASTRA_IMAGE))

clean-astra:
	$(call check_version)
	@docker rmi $(call astra_runtime_name,$(V)) 2>/dev/null || true
	@docker rmi $(call astra_build_name,$(V)) 2>/dev/null || true
	@buildah rmi $(call astra_runtime_name,$(V)) 2>/dev/null || true
	@buildah rmi $(call astra_build_name,$(V)) 2>/dev/null || true
	@rm -f $(ARTIFACTS_IMAGES)/buildah-astra-$(V)-build.tar
	@rm -f $(ARTIFACTS_IMAGES)/buildah-astra-$(V)-runtime.tar
	@rm -f $(ARTIFACTS_BUILD)/buildah-astra-$(V).tar.gz
	@rm -f $(ARTIFACTS_SRC)/buildah-$(V).tar.gz

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

# --- Общее ---
clean:
	@for v in $(BUILDAH_VERSIONS); do $(MAKE) clean-astra V=$$v; done
	@$(MAKE) clean-debian
	@rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V)) T=$(T) $(if $(G),G=$(G))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V)) T=$(T) $(if $(G),G=$(G))

# Catch-all: версия как цель (например, make docker/test-astra 1.38.0)
$(BUILDAH_VERSIONS):
	@:

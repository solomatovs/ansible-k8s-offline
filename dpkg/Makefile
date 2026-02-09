-include config.local.mk
-include config.mk

BASE_IMAGE    := astra-linux:2.12
DPKG_VERSIONS := 1.23.5

# Версия из командной строки: make docker/image 1.23.5
_VERSION_ARGS := $(filter $(DPKG_VERSIONS),$(MAKECMDGOALS))
V := $(or $(V),$(firstword $(_VERSION_ARGS)))
T ?= runtime

# libmd версия для каждой версии dpkg
# Переопределение: make docker/image 1.23.5 L=1.2.0
LIBMD_1.23.5 := 1.1.0

L ?= $(LIBMD_$(V))

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

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

# --- Имена образов ---
image_name   = dpkg-astra:$(1)-build
runtime_name = dpkg-astra:$(1)-runtime

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=dpkg-astra \
	--label org.opencontainers.image.version=$(1)-$(2) \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные для текущих V и T ---
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),Dockerfile.runtime,Dockerfile)

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg DPKG_VERSION=$(V) --build-arg LIBMD_VERSION=$(L))

_LABELS     = $(call labels,$(V),$(T))
_TAR_NAME   = dpkg-astra-$(V)-$(T).tar
_TEST_CMD   = $(if $(filter runtime,$(T)),dpkg --version,sh -c '/out/usr/bin/dpkg --version && (ldd /out/usr/bin/dpkg 2>&1 || echo "static: ok")')

# --- Валидация и ensure ---
check_version = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 1.23.5)"; echo "Поддерживаемые версии: $(DPKG_VERSIONS)"; exit 1; fi
check_libmd   = @if [ -z "$(L)" ]; then echo "Ошибка: версия libmd не задана для dpkg $(V)"; echo "Добавьте LIBMD_$(V) := X.Y.Z в Makefile или задайте L=X.Y.Z"; exit 1; fi

ensure         = @$(_INSPECT) $(call image_name,$(1)) > /dev/null 2>&1 || $(MAKE) image V=$(1) T=build
ensure_runtime = @$(_INSPECT) $(call runtime_name,$(1)) > /dev/null 2>&1 || $(MAKE) image V=$(1) T=runtime

_pre_image = $(if $(filter runtime,$(T)),$(call ensure,$(V)),@:)
_pre_run   = $(if $(filter runtime,$(T)),$(call ensure_runtime,$(V)),$(call ensure,$(V)))

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean $(DPKG_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z [L=ver]    Скачать исходники dpkg и libmd (требует интернет)"
	@echo "  image     X.Y.Z [T=type]   Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z [T=type]   Проверить dpkg --version"
	@echo "  shell     X.Y.Z [T=type]   Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(DPKG_VERSIONS)"
	@echo "  Типы образов (T): runtime (по умолчанию), build"
	@echo "  libmd (L):$(foreach v,$(DPKG_VERSIONS), $(v)→$(LIBMD_$(v)))"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 1.23.5"
	@echo "    make docker/image 1.23.5 T=build"
	@echo "    make docker/build 1.23.5"
	@echo "    make docker/test  1.23.5"
	@echo "    make docker/clean 1.23.5"

# --- Скачивание исходников ---
download:
	$(call check_version)
	$(call check_libmd)
	@$(MAKE) $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz $(ARTIFACTS_SRC)/libmd-$(L).tar.xz

$(ARTIFACTS_SRC)/dpkg_%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(DEBIAN_MIRROR)/pool/main/d/dpkg/dpkg_$*.tar.xz

$(ARTIFACTS_SRC)/libmd-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(HADRONS_MIRROR)/software/libmd/libmd-$*.tar.xz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_libmd))
	$(_pre_image)
	$(if $(filter build,$(T)),@$(MAKE) $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz $(ARTIFACTS_SRC)/libmd-$(L).tar.xz)
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/dpkg-astra-$(V).tar.gz)

test:
	$(call check_version)
	$(_pre_run)
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),$(_TEST_CMD))

shell:
	$(call check_version)
	$(_pre_run)
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(call runtime_name,$(V)) 2>/dev/null || true; \
	  docker rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call runtime_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/dpkg-astra-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/dpkg-astra-$(V)-runtime.tar; \
	  rm -f $(ARTIFACTS_BUILD)/dpkg-astra-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz; \
	  rm -f $(ARTIFACTS_SRC)/libmd-$(L).tar.xz; \
	else \
	  for v in $(DPKG_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V)) T=$(T) $(if $(L),L=$(L))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V)) T=$(T) $(if $(L),L=$(L))

# Catch-all: версия как цель (например, make docker/image 1.23.5)
$(DPKG_VERSIONS):
	@:

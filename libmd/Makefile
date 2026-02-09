-include config.local.mk
-include config.mk

BASE_IMAGE     := astra-linux:2.12
LIBMD_VERSIONS := 1.1.0

# Версия из командной строки: make docker/image 1.1.0
_VERSION_ARGS := $(filter $(LIBMD_VERSIONS),$(MAKECMDGOALS))
V := $(or $(V),$(firstword $(_VERSION_ARGS)))
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
image_name = libmd-astra:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=libmd-astra \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg LIBMD_VERSION=$(V)
_LABELS     = $(call labels,$(V))
_TAR_NAME   = libmd-astra-$(V)-build.tar
_TEST_CMD   = sh -c 'test -f /out/usr/lib/libmd.a && test -f /out/usr/include/md5.h && ls -lh /out/usr/lib/libmd.a && echo "libmd build: ok"'

# --- Валидация и ensure ---
check_version = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 1.1.0)"; echo "Поддерживаемые версии: $(LIBMD_VERSIONS)"; exit 1; fi

ensure = @$(_INSPECT) $(call image_name,$(1)) > /dev/null 2>&1 || $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean $(LIBMD_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники libmd (требует интернет)"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить libmd.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(LIBMD_VERSIONS)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 1.1.0"
	@echo "    make docker/build 1.1.0"
	@echo "    make docker/test  1.1.0"
	@echo "    make docker/clean 1.1.0"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/libmd-$(V).tar.xz

$(ARTIFACTS_SRC)/libmd-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(HADRONS_MIRROR)/software/libmd/libmd-$*.tar.xz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/libmd-$(V).tar.xz
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f Dockerfile \
	  -t $(_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

build:
	$(call check_version)
	$(call ensure,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/libmd-astra-$(V).tar.gz)

test:
	$(call check_version)
	$(call ensure,$(V))
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),$(_TEST_CMD))

shell:
	$(call check_version)
	$(call ensure,$(V))
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/libmd-astra-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/libmd-astra-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/libmd-$(V).tar.xz; \
	else \
	  for v in $(LIBMD_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: версия как цель (например, make docker/image 1.1.0)
$(LIBMD_VERSIONS):
	@:

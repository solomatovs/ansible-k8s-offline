-include config.local.mk
-include config.mk

BASE_IMAGE        := astra-linux:2.12
include ../mk/versions.mk
SELINUX_VERSIONS := $(VERSIONS)
ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

SELINUX_ARCHIVE_URL = $(GITHUB_URL)/SELinuxProject/selinux/archive/refs/tags

SP ?= $(SEPOL_VERSION)

include ../mk/backend.mk

# --- Имена образов ---
image_name = libselinux:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=libselinux \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg SELINUX_VERSION=$(V) \
	$(if $(SP),--build-arg SEPOL_VERSION=$(SP))
_LABELS     = $(call labels,$(V))
_TAR_NAME   = libselinux-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libselinux.a && \
	test -f /out/usr/lib/libsepol.a && \
	test -f /out/usr/include/selinux/selinux.h && \
	ls -lh /out/usr/lib/libselinux.a /out/usr/lib/libsepol.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libselinux.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libselinux.pc && \
	echo "" && echo "libselinux build: ok"'

# --- Валидация и ensure ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 2.6)"; echo "Поддерживаемые версии: $(SELINUX_VERSIONS)"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/libselinux-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/libselinux-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean $(SELINUX_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники libselinux + libsepol (требует интернет)"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить libselinux.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(SELINUX_VERSIONS)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 2.6"
	@echo "    make docker/build 2.6"
	@echo "    make docker/test  2.6"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/libselinux-$(V).tar.gz $(ARTIFACTS_SRC)/libsepol-$(SP).tar.gz

$(ARTIFACTS_SRC)/libselinux-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SELINUX_ARCHIVE_URL)/libselinux-$*.tar.gz

$(ARTIFACTS_SRC)/libsepol-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SELINUX_ARCHIVE_URL)/libsepol-$*.tar.gz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(call check_src_file)
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/libselinux-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/libselinux-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/libselinux-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/libselinux-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/libsepol-$(SP).tar.gz; \
	else \
	  for v in $(SELINUX_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: версия как цель
$(SELINUX_VERSIONS):
	@:

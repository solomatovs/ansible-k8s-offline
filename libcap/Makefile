-include config.local.mk
-include config.mk

BASE_IMAGE       := astra-linux:2.12
include ../mk/versions.mk
LIBCAP_VERSIONS := $(VERSIONS)
ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

LIBCAP_ARCHIVE_URL = $(KERNEL_URL)/linux/libs/security/linux-privs/libcap2

include ../mk/backend.mk

# --- Имена образов ---
image_name = libcap:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=libcap \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg LIBCAP_VERSION=$(V)
_LABELS     = $(call labels,$(V))
_TAR_NAME   = libcap-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcap.a && \
	test -f /out/usr/include/sys/capability.h && \
	ls -lh /out/usr/lib/libcap.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libcap.a && echo "" && \
	echo "=== no .so files ===" && \
	(find /out -name "*.so*" | grep . && echo "FAIL: shared libraries found" && exit 1 || echo "ok: no shared libraries") && \
	echo "" && echo "libcap build: ok"'

# --- Валидация и ensure ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 2.25)"; echo "Поддерживаемые версии: $(LIBCAP_VERSIONS)"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/libcap-$(V).tar.xz || (echo "Ошибка: $(ARTIFACTS_SRC)/libcap-$(V).tar.xz не найден"; echo "Выполните: make download $(V)"; exit 1)

ensure = @$(_INSPECT) $(call image_name,$(1)) > /dev/null 2>&1 || $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean $(LIBCAP_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники libcap (требует интернет)"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить libcap.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(LIBCAP_VERSIONS)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 2.25"
	@echo "    make docker/build 2.25"
	@echo "    make docker/test  2.25"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/libcap-$(V).tar.xz

$(ARTIFACTS_SRC)/libcap-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(LIBCAP_ARCHIVE_URL)/libcap-$*.tar.xz

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(call check_src_file)
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(or $(DOCKERFILE),Dockerfile) \
	  -t $(_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

build:
	$(call check_version)
	$(call ensure,$(V))
	mkdir -p $(ARTIFACTS_BUILD)
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/libcap-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/libcap-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/libcap-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/libcap-$(V).tar.xz; \
	else \
	  for v in $(LIBCAP_VERSIONS); do $(MAKE) clean V=$$v; done; \
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
$(LIBCAP_VERSIONS):
	@:

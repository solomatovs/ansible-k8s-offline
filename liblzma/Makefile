-include config.local.mk
-include config.mk

BASE_IMAGE       := astra-linux:2.12
include ../mk/versions.mk
LZMA_VERSIONS := $(VERSIONS)
ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

LZMA_ARCHIVE_URL = $(XZ_MIRROR)

include ../mk/backend.mk

# --- Имена образов ---
image_name = liblzma:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=liblzma \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg LZMA_VERSION=$(V)
_LABELS     = $(call labels,$(V))
_TAR_NAME   = liblzma-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/liblzma.a && \
	test -f /out/usr/include/lzma.h && \
	test -f /out/usr/lib/pkgconfig/liblzma.pc && \
	ls -lh /out/usr/lib/liblzma.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/liblzma.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/liblzma.pc && \
	echo "" && echo "liblzma build: ok"'

# --- Валидация и ensure ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 5.2.2)"; echo "Поддерживаемые версии: $(LZMA_VERSIONS)"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/xz-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/xz-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)

ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download image build test shell clean $(LZMA_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники xz-utils (требует интернет)"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить liblzma.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(LZMA_VERSIONS)"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 5.2.2"
	@echo "    make docker/build 5.2.2"
	@echo "    make docker/test  5.2.2"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/xz-$(V).tar.gz

$(ARTIFACTS_SRC)/xz-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(LZMA_ARCHIVE_URL)/xz-$*.tar.gz

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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/liblzma-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/liblzma-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/liblzma-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/xz-$(V).tar.gz; \
	else \
	  for v in $(LZMA_VERSIONS); do $(MAKE) clean V=$$v; done; \
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
$(LZMA_VERSIONS):
	@:

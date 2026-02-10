-include config.local.mk
-include config.mk

BASE_IMAGE         := astra-linux:2.12
include ../mk/versions.mk
SYSTEMD_VERSIONS := $(VERSIONS)

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

# Мажорные версии (241) в systemd, patch-версии (241) в systemd-stable
SYSTEMD_ARCHIVE_URL = $(GITHUB_URL)/systemd/systemd/archive/refs/tags

LC ?= $(LIBCAP_VERSION)
LM ?= $(LIBMOUNT_VERSION)
GE ?= $(GPG_ERROR_VERSION)
GC ?= $(GCRYPT_VERSION)
SC ?= $(SECCOMP_VERSION)
XZ ?= $(LZMA_VERSION)
LZ ?= $(LZ4_VERSION)
SE ?= $(SELINUX_VERSION)

# Имена файлов бинарных зависимостей (условные — пустые если версия не задана)
_LIBCAP_DEP     = $(if $(LC),$(ARTIFACTS_DEPS)/libcap-$(LC).tar.gz)
_LIBMOUNT_DEP   = $(if $(LM),$(ARTIFACTS_DEPS)/libmount-$(LM).tar.gz)
_GPG_ERROR_DEP  = $(if $(GE),$(ARTIFACTS_DEPS)/libgpg-error-$(GE).tar.gz)
_GCRYPT_DEP     = $(if $(GC),$(ARTIFACTS_DEPS)/libgcrypt-$(GC).tar.gz)
_SECCOMP_DEP    = $(if $(SC),$(ARTIFACTS_DEPS)/libseccomp-$(SC).tar.gz)
_LZMA_DEP       = $(if $(XZ),$(ARTIFACTS_DEPS)/liblzma-$(XZ).tar.gz)
_LZ4_DEP        = $(if $(LZ),$(ARTIFACTS_DEPS)/liblz4-$(LZ).tar.gz)
_SELINUX_DEP    = $(if $(SE),$(ARTIFACTS_DEPS)/libselinux-$(SE).tar.gz)

# Список активных deps (пустые автоматически исключаются)
_ALL_DEPS = $(strip $(_LIBCAP_DEP) $(_LIBMOUNT_DEP) $(_GPG_ERROR_DEP) $(_GCRYPT_DEP) $(_SECCOMP_DEP) $(_LZMA_DEP) $(_LZ4_DEP) $(_SELINUX_DEP))

include ../mk/backend.mk
include ../mk/deps.mk

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,libcap,libcap))
$(eval $(call dep_rule,libmount,libmount))
$(eval $(call dep_rule,libgpg-error,libgpg-error))
$(eval $(call dep_rule,libgcrypt,libgcrypt))
$(eval $(call dep_rule,libseccomp,libseccomp))
$(eval $(call dep_rule,liblzma,liblzma))
$(eval $(call dep_rule,liblz4,liblz4))
$(eval $(call dep_rule,libselinux,libselinux))

# --- Имена образов ---
image_name = libsystemd:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=libsystemd \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg SYSTEMD_VERSION=$(V) \
	$(if $(LC),--build-arg LIBCAP_VERSION=$(LC)) \
	$(if $(LM),--build-arg LIBMOUNT_VERSION=$(LM)) \
	$(if $(GE),--build-arg GPG_ERROR_VERSION=$(GE)) \
	$(if $(GC),--build-arg GCRYPT_VERSION=$(GC)) \
	$(if $(SC),--build-arg SECCOMP_VERSION=$(SC)) \
	$(if $(XZ),--build-arg LZMA_VERSION=$(XZ)) \
	$(if $(LZ),--build-arg LZ4_VERSION=$(LZ)) \
	$(if $(SE),--build-arg SELINUX_VERSION=$(SE))
_LABELS     = $(call labels,$(V))
_TAR_NAME   = libsystemd-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libsystemd.a && \
	test -f /out/usr/include/systemd/sd-journal.h && \
	test -f /out/usr/lib/pkgconfig/libsystemd.pc && \
	ls -lh /out/usr/lib/libsystemd.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libsystemd.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libsystemd.pc && \
	echo "" && echo "libsystemd build: ok"'

# --- Валидация и ensure ---
check_version       = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 241)"; echo "Поддерживаемые версии: $(SYSTEMD_VERSIONS)"; exit 1; fi
check_src_file      = @test -f $(ARTIFACTS_SRC)/systemd-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/systemd-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)
ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean $(SYSTEMD_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники systemd (требует интернет)"
	@echo "  deps      X.Y.Z            Извлечь C-зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить libsystemd.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(SYSTEMD_VERSIONS)"
	@echo ""
	@echo "  Зависимости (deps):"
	@echo "    libcap:<LC>-build          → artifacts/deps/"
	@echo "    libmount:<LM>-build        → artifacts/deps/"
	@echo "    libgpg-error:<GE>-build    → artifacts/deps/"
	@echo "    libgcrypt:<GC>-build       → artifacts/deps/"
	@echo "    libseccomp:<SC>-build      → artifacts/deps/"
	@echo "    liblzma:<XZ>-build         → artifacts/deps/"
	@echo "    liblz4:<LZ>-build          → artifacts/deps/"
	@echo "    libselinux:<SE>-build      → artifacts/deps/"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 241"
	@echo "    make docker/deps  241"
	@echo "    make docker/build 241"
	@echo "    make docker/test  241"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/systemd-$(V).tar.gz

$(ARTIFACTS_SRC)/systemd-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SYSTEMD_ARCHIVE_URL)/v$*.tar.gz

# --- Извлечение бинарных зависимостей из Docker-образов ---
deps:
	$(call check_version)
	@$(MAKE) $(_ALL_DEPS)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(call check_src_file)
	@$(foreach d,$(_ALL_DEPS),$(call check_dep,$(d)))
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/libsystemd-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/libsystemd-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/libsystemd-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/systemd-$(V).tar.gz; \
	else \
	  for v in $(SYSTEMD_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS); \
	fi
	$(foreach d,$(_ALL_DEPS),@rm -f $(d)
	)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: версия как цель
$(SYSTEMD_VERSIONS):
	@:

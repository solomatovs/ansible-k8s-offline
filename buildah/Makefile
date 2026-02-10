-include config.local.mk
-include config.mk

BUILDAH_REPO     := $(GITHUB_URL)/containers/buildah.git
include ../mk/versions.mk
BUILDAH_VERSIONS := $(VERSIONS)
T ?= runtime

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

BUILDAH_ARCHIVE_URL = $(BUILDAH_REPO:.git=)/archive/refs/tags

include ../mk/backend.mk
include ../mk/deps.mk

# --- Astra Linux ---
ASTRA_BASE_IMAGE := astra-linux:2.12

# Короткие алиасы (значения из versions/<V>.mk)
# Переопределение: make docker/image-astra 1.38.0 G=1.24.5
G  ?= $(GO_VERSION)
DM ?= $(DEVMAPPER_VERSION)
BT ?= $(BTRFS_VERSION)
SC ?= $(SECCOMP_VERSION)
SD ?= $(SYSTEMD_VERSION)
LC ?= $(LIBCAP_VERSION)
LM ?= $(LIBMOUNT_VERSION)
GE ?= $(GPG_ERROR_VERSION)
GC ?= $(GCRYPT_VERSION)

# Имена файлов бинарных зависимостей (условные — пустые если версия не задана)
_GO_DEP         = $(if $(G),$(ARTIFACTS_DEPS)/golang-$(G).tar.gz)
_DEVMAPPER_DEP  = $(if $(DM),$(ARTIFACTS_DEPS)/libdevmapper-$(DM).tar.gz)
_BTRFS_DEP      = $(if $(BT),$(ARTIFACTS_DEPS)/libbtrfs-$(BT).tar.gz)
_SECCOMP_DEP    = $(if $(SC),$(ARTIFACTS_DEPS)/libseccomp-$(SC).tar.gz)
_SYSTEMD_DEP    = $(if $(SD),$(ARTIFACTS_DEPS)/libsystemd-$(SD).tar.gz)
_LIBCAP_DEP     = $(if $(LC),$(ARTIFACTS_DEPS)/libcap-$(LC).tar.gz)
_LIBMOUNT_DEP   = $(if $(LM),$(ARTIFACTS_DEPS)/libmount-$(LM).tar.gz)
_GPG_ERROR_DEP  = $(if $(GE),$(ARTIFACTS_DEPS)/libgpg-error-$(GE).tar.gz)
_GCRYPT_DEP     = $(if $(GC),$(ARTIFACTS_DEPS)/libgcrypt-$(GC).tar.gz)

# Список активных deps (пустые автоматически исключаются)
_ALL_DEPS = $(strip $(_GO_DEP) $(_DEVMAPPER_DEP) $(_BTRFS_DEP) $(_SECCOMP_DEP) \
  $(_SYSTEMD_DEP) $(_LIBCAP_DEP) $(_LIBMOUNT_DEP) $(_GPG_ERROR_DEP) $(_GCRYPT_DEP))

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,golang,golang))
$(eval $(call dep_rule,libdevmapper,libdevmapper))
$(eval $(call dep_rule,libbtrfs,libbtrfs))
$(eval $(call dep_rule,libseccomp,libseccomp))
$(eval $(call dep_rule,libsystemd,libsystemd))
$(eval $(call dep_rule,libcap,libcap))
$(eval $(call dep_rule,libmount,libmount))
$(eval $(call dep_rule,libgpg-error,libgpg-error))
$(eval $(call dep_rule,libgcrypt,libgcrypt))

astra_build_name   = buildah:$(1)-build
astra_runtime_name = buildah-astra:$(1)-runtime

astra_build_args = \
	--build-arg BASE_IMAGE=$(ASTRA_BASE_IMAGE) \
	--build-arg BUILDAH_VERSION=$(1) \
	$(if $(G),--build-arg GO_VERSION=$(G)) \
	$(if $(DM),--build-arg DEVMAPPER_VERSION=$(DM)) \
	$(if $(BT),--build-arg BTRFS_VERSION=$(BT)) \
	$(if $(SC),--build-arg SECCOMP_VERSION=$(SC)) \
	$(if $(SD),--build-arg SYSTEMD_VERSION=$(SD)) \
	$(if $(LC),--build-arg LIBCAP_VERSION=$(LC)) \
	$(if $(LM),--build-arg LIBMOUNT_VERSION=$(LM)) \
	$(if $(GE),--build-arg GPG_ERROR_VERSION=$(GE)) \
	$(if $(GC),--build-arg GCRYPT_VERSION=$(GC))

astra_runtime_build_args = \
	--build-arg BASE_IMAGE=$(ASTRA_BASE_IMAGE) \
	--build-arg BUILDAH_IMAGE=$(call astra_build_name,$(1))

astra_labels = \
	--label org.opencontainers.image.title=$(1) \
	--label org.opencontainers.image.version=$(2)-$(3) \
	--label org.opencontainers.image.base.name=$(ASTRA_BASE_IMAGE)

# --- Вычисляемые переменные для текущих V и T ---
_ASTRA_IMAGE      = $(if $(filter build,$(T)),$(call astra_build_name,$(V)),$(call astra_runtime_name,$(V)))
_ASTRA_DOCKERFILE = $(if $(filter build,$(T)),$(or $(DOCKERFILE_BUILD),Dockerfile.astra),$(or $(DOCKERFILE_RUNTIME),Dockerfile.astra-runtime))
_ASTRA_BUILD_ARGS = $(if $(filter build,$(T)),$(call astra_build_args,$(V)),$(call astra_runtime_build_args,$(V)))
_ASTRA_LABELS     = $(call astra_labels,$(if $(filter runtime,$(T)),buildah-astra,buildah),$(V),$(T))
_ASTRA_TAR_NAME   = $(if $(filter runtime,$(T)),buildah-astra,buildah)-$(V)-$(T).tar
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
ensure_astra         = @$(call _ensure_check,$(call astra_build_name,$(1))) $(MAKE) image-astra V=$(1) T=build
ensure_astra_runtime = @$(call _ensure_check,$(call astra_runtime_name,$(1))) $(MAKE) image-astra V=$(1) T=runtime
ensure_debian        = @$(call _ensure_check,$(DEBIAN_RUNTIME_IMAGE)) $(MAKE) image-debian

.DEFAULT_GOAL := help

.PHONY: help download deps \
        image-astra build-astra test-astra shell-astra clean-astra \
        image-debian test-debian shell-debian clean-debian \
        clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Astra Linux (сборка из исходников):"
	@echo "  download     X.Y.Z                   Скачать исходники buildah (требует интернет)"
	@echo "  deps         X.Y.Z [G=comp]          Извлечь бинарные зависимости из Docker-образов в artifacts/deps/"
	@echo "  image-astra  X.Y.Z [T=type] [G=comp] Собрать образ и экспортировать в artifacts/images/"
	@echo "  build-astra  X.Y.Z [G=comp]          Архивировать артефакты в artifacts/build/"
	@echo "  test-astra   X.Y.Z [T=type]          Проверить buildah version"
	@echo "  shell-astra  X.Y.Z [T=type]          Shell в образе"
	@echo "  clean-astra  X.Y.Z                   Удалить образы и артефакты версии"
	@echo ""
	@echo "  Поддерживаемые версии: $(BUILDAH_VERSIONS)"
	@echo "  Типы образов (T): runtime (по умолчанию), build"
	@echo "  Go-компилятор (G): задаётся в versions/<V>.mk"
	@echo ""
	@echo "  Зависимости (deps):"
	@echo "    golang:<G>-build           → artifacts/deps/"
	@echo "    libdevmapper:<DM>-build    → artifacts/deps/"
	@echo "    libbtrfs:<BT>-build        → artifacts/deps/"
	@echo "    libseccomp:<SC>-build      → artifacts/deps/"
	@echo "    libsystemd:<SD>-build      → artifacts/deps/"
	@echo "    libcap:<LC>-build          → artifacts/deps/"
	@echo "    libmount:<LM>-build        → artifacts/deps/"
	@echo "    libgpg-error:<GE>-build    → artifacts/deps/"
	@echo "    libgcrypt:<GC>-build       → artifacts/deps/"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/download 1.38.0"
	@echo "    make docker/deps     1.38.0"
	@echo "    make docker/image-astra 1.38.0 T=build"
	@echo "    make docker/image-astra 1.38.0"
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

# --- Извлечение бинарных зависимостей из Docker-образов ---
deps:
	$(call check_version)
	$(if $(G),$(call check_go))
	@$(MAKE) $(_ALL_DEPS)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

# --- Astra ---
image-astra:
	$(call check_version)
	$(if $(and $(filter build,$(T)),$(G)),$(call check_go))
	$(if $(filter build,$(T)),$(call check_src_file))
	@$(foreach d,$(_ALL_DEPS),$(if $(filter build,$(T)),$(call check_dep,$(d))))
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
	@$(call _extract,$(call astra_build_name,$(V)),$(ARTIFACTS_BUILD)/buildah-$(V).tar.gz)

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
	@rm -f $(ARTIFACTS_IMAGES)/buildah-$(V)-build.tar
	@rm -f $(ARTIFACTS_IMAGES)/buildah-astra-$(V)-runtime.tar
	@rm -f $(ARTIFACTS_BUILD)/buildah-$(V).tar.gz
	@rm -f $(ARTIFACTS_SRC)/buildah-$(V).tar.gz
	$(foreach d,$(_ALL_DEPS),@rm -f $(d)
	)

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
	@rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS)

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

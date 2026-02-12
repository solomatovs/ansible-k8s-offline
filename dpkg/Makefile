-include config.local.mk
-include config.mk

PROJECT       := dpkg
BASE_IMAGE    := astra-linux:2.12
include ../mk/profiles.mk
DPKG_VERSIONS := $(VERSIONS)
T ?= build

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

include ../mk/backend.mk
include ../mk/deps.mk

# --- Хелперы для PF_ ---
_dep_prj = $(word 1,$(subst :, ,$(1)))
_dep_pid = $(word 2,$(subst :, ,$(1)))
_dep_ver = $(shell echo '$(call _dep_pid,$(1))' | sed 's/-r[0-9]*$$//')
_dep_uc  = $(shell echo '$(call _dep_prj,$(1))' | tr 'a-z-' 'A-Z_')

# --- Обработка PF_DEPS: генерация dep files и build-args ---
define _init_dep
$(call _dep_uc,$(1))_VERSION := $(call _dep_ver,$(1))
_ALL_DEP_FILES += $$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz
_DEP_BUILD_ARGS += --build-arg $(call _dep_uc,$(1))_VERSION=$(call _dep_ver,$(1))
endef

define _gen_dep_rule
$$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz:
	@$$(_INSPECT) $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build > /dev/null 2>&1 || \
	  (echo "Error: image $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build not found"; exit 1)
	mkdir -p $$(ARTIFACTS_DEPS)
	@$$(call _extract,$(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build,$$@)
endef

ifdef PF_DEPS
$(foreach dep,$(PF_DEPS),$(eval $(call _init_dep,$(dep))))
$(foreach dep,$(PF_DEPS),$(eval $(call _gen_dep_rule,$(dep))))
endif
_ALL_DEP_FILES := $(strip $(_ALL_DEP_FILES))

# --- Toolchain image ---
_TOOLCHAIN_IMAGE = $(if $(PF_TOOLCHAIN),$(call _dep_prj,$(PF_TOOLCHAIN)):$(call _dep_pid,$(PF_TOOLCHAIN))-build)

# --- Имена образов ---
image_name   = $(PROJECT):$(1)-build
runtime_name = $(PROJECT)-astra:$(1)-runtime

# --- Вычисляемые переменные ---
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),Dockerfile.runtime,$(PF_DOCKERFILE))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg TOOLCHAIN_IMAGE=$(_TOOLCHAIN_IMAGE) --build-arg DPKG_VERSION=$(PF_VERSION) $(_DEP_BUILD_ARGS))

_LABELS     = --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-$(T) \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)
_TAR_NAME   = $(if $(filter runtime,$(T)),$(PROJECT)-astra-$(V)-runtime,$(PROJECT)-$(V)-build).tar
_TEST_CMD   = $(if $(filter runtime,$(T)),dpkg --version,sh -c '/out/usr/bin/dpkg --version && (ldd /out/usr/bin/dpkg 2>&1 || echo "static: ok")')

# --- Валидация ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию"; echo "Поддерживаемые версии: $(DPKG_VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/dpkg_$(PF_VERSION).tar.xz || (echo "Ошибка: $(ARTIFACTS_SRC)/dpkg_$(PF_VERSION).tar.xz не найден"; echo "Выполните: make download $(V)"; exit 1)
ensure         = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1) T=build
ensure_runtime = @$(call _ensure_check,$(call runtime_name,$(1))) $(MAKE) image V=$(1) T=runtime

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean $(DPKG_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники dpkg (требует интернет)"
	@echo "  deps      X.Y.Z [L=ver]    Извлечь бинарные зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     X.Y.Z [T=type]   Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z [T=type]   Проверить dpkg --version"
	@echo "  shell     X.Y.Z [T=type]   Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(DPKG_VERSIONS)"
	@echo "  Типы образов (T): build (по умолчанию), runtime"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 1.23.5"
	@echo "    make docker/image 1.23.5 T=build"
	@echo "    make docker/deps  1.23.5"
	@echo "    make docker/build 1.23.5"
	@echo "    make docker/test  1.23.5"
	@echo "    make docker/clean 1.23.5"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/dpkg_$(PF_VERSION).tar.xz

$(ARTIFACTS_SRC)/dpkg_%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(DEBIAN_MIRROR)/pool/main/d/dpkg/dpkg_$*.tar.xz

# --- Извлечение бинарных зависимостей ---
deps:
	$(call check_version)
	$(if $(_ALL_DEP_FILES),@$(MAKE) $(_ALL_DEP_FILES))

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(if $(filter build,$(T)),$(call check_src_file))
	$(if $(_ALL_DEP_FILES),@$(foreach d,$(_ALL_DEP_FILES),$(if $(filter build,$(T)),$(call check_dep,$(d)))))
	$(if $(filter runtime,$(T)),$(call ensure,$(V)))
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/dpkg-$(PF_VERSION).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/dpkg-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_IMAGES)/dpkg-astra-$(V)-runtime.tar; \
	  rm -f $(ARTIFACTS_BUILD)/dpkg-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/dpkg_$(PF_VERSION).tar.xz; \
	else \
	  for v in $(DPKG_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS); \
	fi
	$(foreach d,$(_ALL_DEP_FILES),@rm -f $(d)
	)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V)) T=$(T)

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V)) T=$(T)

# Catch-all: версия как цель (например, make docker/image 1.23.5)
$(DPKG_VERSIONS):
	@:

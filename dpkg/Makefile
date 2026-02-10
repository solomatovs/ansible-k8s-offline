-include config.local.mk
-include config.mk

BASE_IMAGE    := astra-linux:2.12
include ../mk/versions.mk
DPKG_VERSIONS := $(VERSIONS)
T ?= runtime

L ?= $(LIBMD_VERSION)

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

# Имя файла бинарной зависимости (условное — пустое если версия не задана)
_LIBMD_DEP = $(if $(L),$(ARTIFACTS_DEPS)/libmd-$(L).tar.gz)

# Список активных deps (пустые автоматически исключаются)
_ALL_DEPS = $(strip $(_LIBMD_DEP))

include ../mk/backend.mk
include ../mk/deps.mk

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,libmd,libmd))

# --- Имена образов ---
image_name   = dpkg:$(1)-build
runtime_name = dpkg-astra:$(1)-runtime

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=$(1) \
	--label org.opencontainers.image.version=$(2)-$(3) \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные для текущих V и T ---
_IMAGE      = $(if $(filter runtime,$(T)),$(call runtime_name,$(V)),$(call image_name,$(V)))
_DOCKERFILE = $(if $(filter runtime,$(T)),$(or $(DOCKERFILE_RUNTIME),Dockerfile.runtime),$(or $(DOCKERFILE_BUILD),Dockerfile))

_BUILD_ARGS = $(if $(filter runtime,$(T)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg BUILD_IMAGE=$(call image_name,$(V)),\
  --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg DPKG_VERSION=$(V) $(if $(L),--build-arg LIBMD_VERSION=$(L)))

_LABELS     = $(call labels,$(if $(filter runtime,$(T)),dpkg-astra,dpkg),$(V),$(T))
_TAR_NAME   = $(if $(filter runtime,$(T)),dpkg-astra,dpkg)-$(V)-$(T).tar
_TEST_CMD   = $(if $(filter runtime,$(T)),dpkg --version,sh -c '/out/usr/bin/dpkg --version && (ldd /out/usr/bin/dpkg 2>&1 || echo "static: ok")')

# --- Валидация (внешние зависимости — ошибка если нет) ---
check_version  = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 1.23.5)"; echo "Поддерживаемые версии: $(DPKG_VERSIONS)"; exit 1; fi
check_libmd    = @if [ -z "$(L)" ]; then echo "Ошибка: версия libmd не задана для dpkg $(V)"; echo "Добавьте LIBMD_$(V) := X.Y.Z в Makefile или задайте L=X.Y.Z"; exit 1; fi
check_src_file = @test -f $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz || (echo "Ошибка: $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz не найден"; echo "Выполните: make download $(V)"; exit 1)
# --- Ensure (внутренние зависимости — автосборка если нет) ---
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
	@echo "  Типы образов (T): runtime (по умолчанию), build"
	@echo "  libmd (L): задаётся в versions/<V>.mk"
	@echo ""
	@echo "  Зависимости (deps): libmd:<L>-build → artifacts/deps/"
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
	@$(MAKE) $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz

$(ARTIFACTS_SRC)/dpkg_%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(DEBIAN_MIRROR)/pool/main/d/dpkg/dpkg_$*.tar.xz

# --- Извлечение бинарных зависимостей из Docker-образов ---
deps:
	$(call check_version)
	$(if $(L),$(call check_libmd))
	@$(MAKE) $(_ALL_DEPS)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	$(if $(and $(filter build,$(T)),$(L)),$(call check_libmd))
	$(if $(filter build,$(T)),$(call check_src_file))
	@$(foreach d,$(_ALL_DEPS),$(if $(filter build,$(T)),$(call check_dep,$(d))))
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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/dpkg-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_SRC)/dpkg_$(V).tar.xz; \
	else \
	  for v in $(DPKG_VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_BUILD) $(ARTIFACTS_IMAGES) $(ARTIFACTS_SRC) $(ARTIFACTS_DEPS); \
	fi
	$(foreach d,$(_ALL_DEPS),@rm -f $(d)
	)

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

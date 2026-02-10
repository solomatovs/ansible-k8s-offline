# =============================================================================
# DevOps-образ: rootless buildah + dpkg + golang на Astra Linux
# =============================================================================

-include config.local.mk
-include config.mk

BASE_IMAGE       := astra-linux:2.12
DEVOPS_IMAGE     := devops-astra:latest

# --- Версии внешних зависимостей ---
DPKG_VERSION    ?= 1.23.5
BUILDAH_VERSION ?= 1.38.0
GO_VERSION      ?= 1.24.5

ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_IMAGES := artifacts/images

# Имена файлов бинарных зависимостей
_DPKG_DEP    = $(ARTIFACTS_DEPS)/dpkg-$(DPKG_VERSION).tar.gz
_BUILDAH_DEP = $(ARTIFACTS_DEPS)/buildah-$(BUILDAH_VERSION).tar.gz
_GO_DEP      = $(ARTIFACTS_DEPS)/golang-$(GO_VERSION).tar.gz

include ../mk/backend.mk
include ../mk/deps.mk

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,dpkg,dpkg))
$(eval $(call dep_rule,buildah,buildah))
$(eval $(call dep_rule,golang,golang))

LABELS := \
	--label org.opencontainers.image.title=devops-astra \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg DPKG_VERSION=$(DPKG_VERSION) \
	--build-arg BUILDAH_VERSION=$(BUILDAH_VERSION) \
	--build-arg GO_VERSION=$(GO_VERSION)

# --- Ensure (внутренние зависимости — автосборка если нет) ---
ensure = @$(call _ensure_check,$(DEVOPS_IMAGE)) $(MAKE) image

.DEFAULT_GOAL := help

.PHONY: help deps image test shell clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  deps             Извлечь бинарные зависимости из Docker-образов в artifacts/deps/"
	@echo "  image            Собрать образ и экспортировать в artifacts/images/"
	@echo "  test             Проверить артефакты: dpkg, buildah, go version"
	@echo "  shell            Shell в образе"
	@echo "  clean            Удалить образы и артефакты"
	@echo ""
	@echo "  Зависимости (deps):"
	@echo "    dpkg:$(DPKG_VERSION)-build       → artifacts/deps/"
	@echo "    buildah:$(BUILDAH_VERSION)-build  → artifacts/deps/"
	@echo "    golang:$(GO_VERSION)-build        → artifacts/deps/"
	@echo ""
	@echo "  Переопределение версий:"
	@echo "    make docker/image DPKG_VERSION=1.23.5 BUILDAH_VERSION=1.42.0 GO_VERSION=1.24.5"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/deps"
	@echo "    make docker/image"
	@echo "    make docker/test"

# --- Извлечение бинарных зависимостей из Docker-образов ---
deps:
	@$(MAKE) $(_DPKG_DEP) $(_BUILDAH_DEP) $(_GO_DEP)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	@$(call check_dep,$(_DPKG_DEP))
	@$(call check_dep,$(_BUILDAH_DEP))
	@$(call check_dep,$(_GO_DEP))
	$(_BUILD) \
	  $(BUILD_ARGS) \
	  $(LABELS) \
	  -t $(DEVOPS_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(DEVOPS_IMAGE),$(ARTIFACTS_IMAGES)/devops-astra.tar)

test:
	$(call ensure)
	@echo "=== $(DEVOPS_IMAGE) ==="
	@$(call _run,$(DEVOPS_IMAGE),sh -c 'echo "--- dpkg ---" && /usr/bin/dpkg --version && echo "--- buildah ---" && /usr/bin/buildah version && echo "--- go ---" && /usr/local/go/bin/go version')

shell:
	$(call ensure)
	@$(call _shell,$(DEVOPS_IMAGE))

clean:
	@docker rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@buildah rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES) $(ARTIFACTS_DEPS)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(DPKG_VERSION),DPKG_VERSION=$(DPKG_VERSION)) $(if $(BUILDAH_VERSION),BUILDAH_VERSION=$(BUILDAH_VERSION)) $(if $(GO_VERSION),GO_VERSION=$(GO_VERSION))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(DPKG_VERSION),DPKG_VERSION=$(DPKG_VERSION)) $(if $(BUILDAH_VERSION),BUILDAH_VERSION=$(BUILDAH_VERSION)) $(if $(GO_VERSION),GO_VERSION=$(GO_VERSION))

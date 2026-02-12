# =============================================================================
# toolchain-golang — унифицированный базовый образ для Go-проектов
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := toolchain-golang
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_IMAGES := artifacts/images

# --- Профили ---
include ../mk/profiles.mk

# --- Backend (docker/buildah) ---
include ../mk/backend.mk

# --- Хелперы для парсинга PF_DEPS ---
_dep_prj = $(word 1,$(subst :, ,$(1)))
_dep_pid = $(word 2,$(subst :, ,$(1)))

# --- Вычисляемые переменные из PF_DEPS ---
_GO_DEP    = $(firstword $(PF_DEPS))
_GO_PID    = $(call _dep_pid,$(_GO_DEP))
_GO_IMAGE  = $(call _dep_prj,$(_GO_DEP)):$(_GO_PID)-build

# --- Имя образа ---
_IMAGE = $(PROJECT):$(V)-build

# --- Build args ---
_BUILD_ARGS = \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    --build-arg GOLANG_IMAGE=$(_GO_IMAGE)

_LABELS = \
    --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-build \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE) \
    --label "org.opencontainers.image.description=golang=$(_GO_PID)"

# --- Валидация ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите версию (например, make docker/image $(firstword $(VERSIONS)))"; \
    echo "Поддерживаемые версии: $(VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi

check_image = @$(_INSPECT) $(1) > /dev/null 2>&1 || \
	{ echo "Ошибка: образ $(1) не найден" >&2; \
	  echo "Сначала соберите: make -C ../$(2) docker/image $(3)" >&2; exit 1; }

# =============================================================================
# Targets
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help deps image test shell clean
.PHONY: $(VERSIONS)

help:
	@echo "Usage: make docker/<target> <version>   (на хосте, через Docker)"
	@echo "       make buildah/<target> <version>  (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  image   <version>   Собрать toolchain-образ"
	@echo "  test    <version>   Проверить go version и инструменты"
	@echo "  shell   <version>   Shell в образе"
	@echo "  clean   [version]   Удалить образы"
	@echo ""
	@echo "  Поддерживаемые версии: $(VERSIONS)"
ifdef PF_DEPS
	@echo ""
	@echo "  Текущая версия ($(V)):"
	@echo "    Образ: $(_IMAGE)"
	@echo "    PF_VERSION = $(PF_VERSION)"
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@echo "    $(_GO_IMAGE)"
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image $(firstword $(VERSIONS))"
	@echo "    make docker/test  $(firstword $(VERSIONS))"

deps:
	@:

image:
	$(call check_version)
	$(call check_image,$(_GO_IMAGE),golang,$(call _dep_pid,$(_GO_DEP)))
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(PF_DOCKERFILE) \
	  -t $(_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar)

test:
	$(call check_version)
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),sh -c '\
		echo "--- go ---" && go version && \
		echo "--- env ---" && \
		echo "GOROOT=$$GOROOT" && echo "GOPATH=$$GOPATH" && \
		echo "--- gcc ---" && gcc --version | head -1 && \
		echo "--- tools ---" && \
		make --version | head -1 && \
		pkg-config --version && \
		git --version && \
		echo "toolchain-golang $(V): ok"')

shell:
	$(call check_version)
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(_IMAGE) 2>/dev/null || true; \
	  buildah rmi $(_IMAGE) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar; \
	else \
	  for v in $(VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_IMAGES); \
	fi

# =============================================================================
# Namespace shortcuts
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

$(VERSIONS):
	@:

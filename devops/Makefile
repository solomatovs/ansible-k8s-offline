# =============================================================================
# DevOps-образ: rootless buildah + dpkg + git + golang + gcc + curl на Astra Linux
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := devops
BASE_IMAGE := astra-linux:2.12

include ../mk/profiles.mk

include ../mk/backend.mk

# --- Переопределение _run и _shell для devops ---
# buildah внутри контейнера требует seccomp=unconfined (unshare CLONE_NEWUSER)
ifeq ($(BACKEND),docker)
  _run   = docker run --rm --security-opt seccomp=unconfined $(1) $(2)
  _shell = docker run --rm -it --security-opt seccomp=unconfined $(1) /bin/bash
else
  _run   = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- $(2) && buildah rm "$$ctr" > /dev/null
  _shell = ctr=$$(buildah from $(1)) && buildah run --tty "$$ctr" -- /bin/bash; buildah rm "$$ctr" > /dev/null 2>&1 || true
endif

# --- Имя образа ---
image_name = $(PROJECT):$(1)-build
_IMAGE     = $(call image_name,$(V))
_TAR_NAME  = $(PROJECT)-$(V)-build.tar

# --- Рендеринг Dockerfile ---
_RENDER = ../mk/render-dockerfile.sh $(PROJECT) $(PF_DOCKERFILE)
_RENDERED_FILE = .rendered.Dockerfile

# --- Build args и метки ---
_BUILD_ARGS = \
    --build-arg BASE_IMAGE=$(BASE_IMAGE) \
    $(_DEP_BUILD_ARGS) \
    --build-arg RELEASE_INFO="PROFILE=$(V)"

_LABELS = \
    --label org.opencontainers.image.title=$(PROJECT) \
    --label org.opencontainers.image.version=$(V)-build \
    --label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Валидация ---
check_version = @if [ -z "$(V)" ]; then \
    echo "Ошибка: укажите профиль (например, make docker/build full)"; \
    echo "Доступные профили: $(VERSIONS)"; exit 1; fi; \
    if [ ! -f profiles/$(V).mk ]; then \
    echo "Ошибка: profiles/$(V).mk не найден"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi

ensure = @$(call _ensure_check,$(_IMAGE)) $(MAKE) build V=$(V)

.DEFAULT_GOAL := help

.PHONY: help show-urls show-versions download render build test shell clean $(VERSIONS)

help:
	@echo "Usage: make docker/<target> <profile>   (на хосте, через Docker)"
	@echo "       make buildah/<target> <profile>  (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  render  <profile>   Показать отрендеренный Dockerfile (stdout)"
	@echo "  build   <profile>   Собрать образ и экспортировать в artifacts/images/"
	@echo "  test    <profile>   Проверить артефакты: dpkg, buildah, go version"
	@echo "  shell   <profile>   Shell в образе"
	@echo "  clean   [profile]   Удалить образы и артефакты"
	@echo "  show-versions <profile>  Показать версии инструментов в профиле"
	@echo ""
	@echo "  Доступные профили: $(VERSIONS)"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/build full"
	@echo "    make docker/test  full"

show-versions:
	$(call check_version)
	@echo "devops профиль «$(V)»:"
	@$(foreach dep,$(PF_DEPS),printf '  %-20s = %s\n' '$(call _dep_prj,$(dep))' '$(call _dep_pid,$(dep))';)
	@echo ""
	@echo "  Образ: $(_IMAGE)"

show-urls:
	$(call check_version)
	@$(MAKE) --no-print-directory _list_urls V=$(V) DEST=$(PROJECT)/$(ARTIFACTS_SRC) | sort -u

# --- Скачивание исходников (рекурсивно через _download_to) ---
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

render:
	$(call check_version)
	@$(_RENDER) > $(_RENDERED_FILE)
	@cat $(_RENDERED_FILE)

build:
	$(call check_version)
	@$(MAKE) --no-print-directory _check_src V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
	@$(_RENDER) > $(_RENDERED_FILE)
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(_RENDERED_FILE) \
	  -t $(_IMAGE) ..
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(_IMAGE),$(ARTIFACTS_IMAGES)/$(_TAR_NAME))

test:
	$(call check_version)
	$(call ensure)
	@echo "=== $(_IMAGE) ==="
	@$(call _run,$(_IMAGE),sh -c 'echo "--- release ---" && cat /etc/devops-release && echo "--- dpkg ---" && dpkg --version && echo "--- buildah ---" && buildah version && echo "--- git ---" && git --version && echo "--- gcc ---" && gcc --version | head -1 && echo "--- curl ---" && curl --version | head -1 && echo "--- go ---" && go version && echo "--- make ---" && make --version | head -1')

shell:
	$(call check_version)
	$(call ensure)
	@$(call _shell,$(_IMAGE))

clean:
	@if [ -n "$(V)" ]; then \
	  docker rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  buildah rmi $(call image_name,$(V)) 2>/dev/null || true; \
	  rm -f $(ARTIFACTS_IMAGES)/$(PROJECT)-$(V)-build.tar; \
	else \
	  for v in $(VERSIONS); do $(MAKE) clean V=$$v; done; \
	  rm -rf $(ARTIFACTS_IMAGES); \
	fi

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: профиль как цель (например, make docker/build full)
$(VERSIONS):
	@:

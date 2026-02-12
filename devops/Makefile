# =============================================================================
# DevOps-образ: rootless buildah + dpkg + git + golang + gcc + curl на Astra Linux
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := devops
BASE_IMAGE := astra-linux:2.12

include ../mk/profiles.mk

ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_IMAGES := artifacts/images

include ../mk/backend.mk
include ../mk/deps.mk

# --- Хелперы для PF_ ---
_dep_prj = $(word 1,$(subst :, ,$(1)))
_dep_pid = $(word 2,$(subst :, ,$(1)))
_dep_ver = $(shell echo '$(call _dep_pid,$(1))' | sed 's/-r[0-9]*$$//')
_dep_uc  = $(shell echo '$(call _dep_prj,$(1))' | tr 'a-z-' 'A-Z_')

# --- Обработка PF_DEPS ---
# Все deps получают UC_VERSION и build-arg.
# Tar.gz deps дополнительно получают правила извлечения.
define _init_dep
$(call _dep_uc,$(1))_VERSION := $(call _dep_ver,$(1))
_DEP_BUILD_ARGS += --build-arg $(call _dep_uc,$(1))_VERSION=$(call _dep_ver,$(1))
endef

# Deps извлекаемые как tar.gz (остальные — COPY --from в Dockerfile)
_TAR_DEP_PROJECTS = dpkg buildah git golang

define _gen_dep_rule
$$(ARTIFACTS_DEPS)/$(call _dep_prj,$(1))-$(call _dep_ver,$(1)).tar.gz:
	@$$(_INSPECT) $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build > /dev/null 2>&1 || \
	  (echo "Error: image $(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build not found"; exit 1)
	mkdir -p $$(ARTIFACTS_DEPS)
	@$$(call _extract,$(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build,$$@)
endef

ifdef PF_DEPS
$(foreach dep,$(PF_DEPS),$(eval $(call _init_dep,$(dep))))
$(foreach dep,$(PF_DEPS),\
  $(if $(filter $(call _dep_prj,$(dep)),$(_TAR_DEP_PROJECTS)),\
    $(eval $(call _gen_dep_rule,$(dep)))))
endif

# Tar.gz dep file paths
_TAR_DEP_FILES = $(strip $(foreach dep,$(PF_DEPS),\
  $(if $(filter $(call _dep_prj,$(dep)),$(_TAR_DEP_PROJECTS)),\
    $(ARTIFACTS_DEPS)/$(call _dep_prj,$(dep))-$(call _dep_ver,$(dep)).tar.gz)))

# Image dep references (COPY --from в Dockerfile)
_IMAGE_DEP_REFS = $(strip $(foreach dep,$(PF_DEPS),\
  $(if $(filter-out $(_TAR_DEP_PROJECTS),$(call _dep_prj,$(dep))),\
    $(call _dep_prj,$(dep)):$(call _dep_pid,$(dep))-build)))

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
    echo "Ошибка: укажите профиль (например, make docker/image full-r3)"; \
    echo "Доступные профили: $(VERSIONS)"; exit 1; fi; \
    if [ -z "$(PF_VERSION)" ]; then \
    echo "Ошибка: PF_VERSION не определён в profiles/$(V).mk"; exit 1; fi

ensure = @$(call _ensure_check,$(_IMAGE)) $(MAKE) image V=$(V)

.DEFAULT_GOAL := help

.PHONY: help show-versions deps image test shell clean $(VERSIONS)

help:
	@echo "Usage: make docker/<target> <profile>   (на хосте, через Docker)"
	@echo "       make buildah/<target> <profile>  (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  deps    <profile>   Извлечь бинарные зависимости из Docker-образов в artifacts/deps/"
	@echo "  image   <profile>   Собрать образ и экспортировать в artifacts/images/"
	@echo "  test    <profile>   Проверить артефакты: dpkg, buildah, go version"
	@echo "  shell   <profile>   Shell в образе"
	@echo "  clean   <profile>   Удалить образы и артефакты"
	@echo "  show-versions <profile>  Показать версии инструментов в профиле"
	@echo ""
	@echo "  Доступные профили: $(VERSIONS)"
ifdef PF_DEPS
	@echo ""
	@echo "  Зависимости (PF_DEPS):"
	@$(foreach dep,$(PF_DEPS),printf '    %s\n' '$(dep)';)
	@echo ""
	@echo "  Image deps (COPY --from в Dockerfile):"
	@$(foreach img,$(_IMAGE_DEP_REFS),printf '    %s\n' '$(img)';)
	@echo ""
	@echo "  Tar.gz deps (извлекаются в artifacts/deps/):"
	@$(foreach f,$(_TAR_DEP_FILES),printf '    %s\n' '$(f)';)
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/deps full-r3"
	@echo "    make docker/image full-r3"
	@echo "    make docker/test full-r3"

show-versions:
	$(call check_version)
	@echo "devops профиль «$(V)»:"
	@$(foreach dep,$(PF_DEPS),printf '  %-20s = %s\n' '$(call _dep_uc,$(dep))_VERSION' '$(call _dep_ver,$(dep))';)
	@echo ""
	@echo "  Образ: $(_IMAGE)"

# --- Извлечение бинарных зависимостей ---
deps:
	$(call check_version)
	$(if $(_TAR_DEP_FILES),@$(MAKE) $(_TAR_DEP_FILES))

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_version)
	@$(foreach img,$(_IMAGE_DEP_REFS),\
	  $(_INSPECT) $(img) > /dev/null 2>&1 || \
	  { echo "Error: image $(img) not found" >&2; exit 1; };)
	@$(foreach f,$(_TAR_DEP_FILES),$(call check_dep,$(f)))
	$(_BUILD) \
	  $(_BUILD_ARGS) \
	  $(_LABELS) \
	  -f $(PF_DOCKERFILE) \
	  -t $(_IMAGE) .
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
	$(call check_version)
	@docker rmi $(_IMAGE) 2>/dev/null || true
	@buildah rmi $(_IMAGE) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES) $(ARTIFACTS_DEPS)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(V),V=$(V))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(V),V=$(V))

# Catch-all: профиль как цель (например, make docker/image full-r3)
$(VERSIONS):
	@:

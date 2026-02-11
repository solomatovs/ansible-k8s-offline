# =============================================================================
# DevOps-образ: rootless buildah + dpkg + git + golang + gcc + curl на Astra Linux
# =============================================================================

-include config.local.mk
-include config.mk

BASE_IMAGE := astra-linux:2.12

# --- Обнаружение профилей ---
PROFILES := $(sort $(basename $(notdir $(wildcard profiles/*.mk))))
_PROFILE_ARGS := $(filter $(PROFILES),$(MAKECMDGOALS))
P := $(or $(P),$(firstword $(_PROFILE_ARGS)))

ifdef P
-include profiles/$(P).mk
endif

check_profile = @if [ -z "$(P)" ]; then \
    echo "Ошибка: укажите профиль (например, make docker/image full)"; \
    echo "Доступные профили: $(PROFILES)"; exit 1; fi

# --- Имя образа ---
DEVOPS_IMAGE = devops-astra:$(P)-v$(PROFILE_VERSION)

ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_IMAGES := artifacts/images

# --- Зависимости ---
# Образы (COPY --from в Dockerfile):
#   glibc, libstdcxx — замена системной glibc/libstdc++ на новые версии
#   gcc             — компилятор (замена apt gcc + libc6-dev)
#   curl + 12 deps  — CLI + shared libraries (замена apt curl)
_GLIBC_IMAGE     = glibc:$(GLIBC_VERSION)-build
_LIBSTDCXX_IMAGE = libstdcxx:$(LIBSTDCXX_VERSION)-build
_GCC_IMAGE       = gcc:$(GCC_VERSION)-build

# curl и все его runtime shared library зависимости (бандл через curl-bundle stage)
_CURL_IMAGES = \
    zlib:$(ZLIB_VERSION)-build \
    openssl:$(OPENSSL_VERSION)-build \
    kerberos:$(KERBEROS_VERSION)-build \
    nghttp2:$(NGHTTP2_VERSION)-build \
    openldap:$(OPENLDAP_VERSION)-build \
    libssh2:$(LIBSSH2_VERSION)-build \
    libunistring:$(LIBUNISTRING_VERSION)-build \
    libidn2:$(LIBIDN2_VERSION)-build \
    zstd:$(ZSTD_VERSION)-build \
    brotli:$(BROTLI_VERSION)-build \
    nghttp3:$(NGHTTP3_VERSION)-build \
    ngtcp2:$(NGTCP2_VERSION)-build \
    curl:$(CURL_VERSION)-build

# tar.gz-зависимости (извлекаются из Docker-образов через make deps)
_DPKG_DEP    = $(ARTIFACTS_DEPS)/dpkg-$(DPKG_VERSION).tar.gz
_BUILDAH_DEP = $(ARTIFACTS_DEPS)/buildah-$(BUILDAH_VERSION).tar.gz
_GIT_DEP     = $(ARTIFACTS_DEPS)/git-$(GIT_VERSION).tar.gz
_GO_DEP      = $(ARTIFACTS_DEPS)/golang-$(GO_VERSION).tar.gz

include ../mk/backend.mk
include ../mk/deps.mk

# Переопределяем _run и _shell — devops-контейнеру нужен seccomp=unconfined
# для работы buildah (unshare CLONE_NEWUSER заблокирован по умолчанию).
ifeq ($(BACKEND),docker)
  _run   = docker run --rm --security-opt seccomp=unconfined $(1) $(2)
  _shell = docker run --rm -it --security-opt seccomp=unconfined $(1) /bin/bash
else
  _run   = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- $(2) && buildah rm "$$ctr" > /dev/null
  _shell = ctr=$$(buildah from $(1)) && buildah run --tty "$$ctr" -- /bin/bash; buildah rm "$$ctr" > /dev/null 2>&1 || true
endif

# Проверка наличия Docker-образа
check_image = @docker inspect $(1) > /dev/null 2>&1 || \
	{ echo "Ошибка: образ $(1) не найден" >&2; \
	  echo "Сначала соберите: make -C ../$(2) docker/image $(3)" >&2; exit 1; };

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,dpkg,dpkg))
$(eval $(call dep_rule,buildah,buildah))
$(eval $(call dep_rule,git,git))
$(eval $(call dep_rule,golang,golang))

# --- Build args и метки ---
_RELEASE_INFO = PROFILE=$(P)\nPROFILE_VERSION=$(PROFILE_VERSION)\nGLIBC_VERSION=$(GLIBC_VERSION)\nLIBSTDCXX_VERSION=$(LIBSTDCXX_VERSION)\nGCC_VERSION=$(GCC_VERSION)\nCURL_VERSION=$(CURL_VERSION)\nDPKG_VERSION=$(DPKG_VERSION)\nBUILDAH_VERSION=$(BUILDAH_VERSION)\nGIT_VERSION=$(GIT_VERSION)\nGO_VERSION=$(GO_VERSION)
_DESCRIPTION = glibc=$(GLIBC_VERSION) libstdc++=$(LIBSTDCXX_VERSION) gcc=$(GCC_VERSION) curl=$(CURL_VERSION) dpkg=$(DPKG_VERSION) buildah=$(BUILDAH_VERSION) git=$(GIT_VERSION) go=$(GO_VERSION)

LABELS := \
	--label org.opencontainers.image.title=devops-astra \
	--label org.opencontainers.image.version=$(P)-v$(PROFILE_VERSION) \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE) \
	--label "org.opencontainers.image.description=$(_DESCRIPTION)"

BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GLIBC_VERSION=$(GLIBC_VERSION) \
	--build-arg LIBSTDCXX_VERSION=$(LIBSTDCXX_VERSION) \
	--build-arg GCC_VERSION=$(GCC_VERSION) \
	--build-arg CURL_VERSION=$(CURL_VERSION) \
	--build-arg ZLIB_VERSION=$(ZLIB_VERSION) \
	--build-arg OPENSSL_VERSION=$(OPENSSL_VERSION) \
	--build-arg KERBEROS_VERSION=$(KERBEROS_VERSION) \
	--build-arg NGHTTP2_VERSION=$(NGHTTP2_VERSION) \
	--build-arg OPENLDAP_VERSION=$(OPENLDAP_VERSION) \
	--build-arg LIBSSH2_VERSION=$(LIBSSH2_VERSION) \
	--build-arg LIBUNISTRING_VERSION=$(LIBUNISTRING_VERSION) \
	--build-arg LIBIDN2_VERSION=$(LIBIDN2_VERSION) \
	--build-arg ZSTD_VERSION=$(ZSTD_VERSION) \
	--build-arg BROTLI_VERSION=$(BROTLI_VERSION) \
	--build-arg NGHTTP3_VERSION=$(NGHTTP3_VERSION) \
	--build-arg NGTCP2_VERSION=$(NGTCP2_VERSION) \
	--build-arg DPKG_VERSION=$(DPKG_VERSION) \
	--build-arg BUILDAH_VERSION=$(BUILDAH_VERSION) \
	--build-arg GIT_VERSION=$(GIT_VERSION) \
	--build-arg GO_VERSION=$(GO_VERSION) \
	--build-arg RELEASE_INFO="$(_RELEASE_INFO)"

# --- Ensure (внутренние зависимости — автосборка если нет) ---
ensure = @$(call _ensure_check,$(DEVOPS_IMAGE)) $(MAKE) image P=$(P)

.DEFAULT_GOAL := help

.PHONY: help show-versions deps image test shell clean
.PHONY: $(PROFILES)

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
	@echo "  Доступные профили: $(PROFILES)"
ifdef P
	@echo ""
	@echo "  Текущий профиль ($(P)):"
	@echo "    Образ: $(DEVOPS_IMAGE)"
	@echo "    glibc=$(GLIBC_VERSION) libstdc++=$(LIBSTDCXX_VERSION) gcc=$(GCC_VERSION) curl=$(CURL_VERSION)"
	@echo "    dpkg=$(DPKG_VERSION) buildah=$(BUILDAH_VERSION) git=$(GIT_VERSION) go=$(GO_VERSION)"
	@echo ""
	@echo "  Образы (COPY --from в Dockerfile):"
	@echo "    glibc:$(GLIBC_VERSION)-build"
	@echo "    libstdcxx:$(LIBSTDCXX_VERSION)-build"
	@echo "    gcc:$(GCC_VERSION)-build"
	@echo "    curl:$(CURL_VERSION)-build + 12 runtime deps"
	@echo "  Зависимости (deps → artifacts/deps/):"
	@echo "    dpkg:$(DPKG_VERSION)-build"
	@echo "    buildah:$(BUILDAH_VERSION)-build"
	@echo "    git:$(GIT_VERSION)-build"
	@echo "    golang:$(GO_VERSION)-build"
endif
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/deps full"
	@echo "    make docker/image full"
	@echo "    make docker/test full"
	@echo "    make docker/show-versions full"

show-versions:
	$(call check_profile)
	@echo "devops-astra профиль «$(P)» v$(PROFILE_VERSION):"
	@echo "  GLIBC_VERSION     = $(GLIBC_VERSION)"
	@echo "  LIBSTDCXX_VERSION = $(LIBSTDCXX_VERSION)"
	@echo "  GCC_VERSION       = $(GCC_VERSION)"
	@echo "  CURL_VERSION      = $(CURL_VERSION)"
	@echo "  DPKG_VERSION      = $(DPKG_VERSION)"
	@echo "  BUILDAH_VERSION   = $(BUILDAH_VERSION)"
	@echo "  GIT_VERSION       = $(GIT_VERSION)"
	@echo "  GO_VERSION        = $(GO_VERSION)"
	@echo ""
	@echo "  Образ: $(DEVOPS_IMAGE)"

# --- Извлечение бинарных зависимостей из Docker-образов ---
deps:
	$(call check_profile)
	@$(MAKE) $(_DPKG_DEP) $(_BUILDAH_DEP) $(_GIT_DEP) $(_GO_DEP)

# =============================================================================
# Targets (backend выбирается через BACKEND)
# =============================================================================

image:
	$(call check_profile)
	$(call check_image,$(_GLIBC_IMAGE),glibc,$(GLIBC_VERSION))
	$(call check_image,$(_LIBSTDCXX_IMAGE),libstdcxx,$(LIBSTDCXX_VERSION))
	$(call check_image,$(_GCC_IMAGE),gcc,$(GCC_VERSION))
	$(foreach img,$(_CURL_IMAGES),$(call check_image,$(img),$(firstword $(subst :, ,$(img))),$(lastword $(subst -, ,$(lastword $(subst :, ,$(img)))))))
	@$(call check_dep,$(_DPKG_DEP))
	@$(call check_dep,$(_BUILDAH_DEP))
	@$(call check_dep,$(_GIT_DEP))
	@$(call check_dep,$(_GO_DEP))
	$(_BUILD) \
	  $(BUILD_ARGS) \
	  $(LABELS) \
	  -t $(DEVOPS_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	$(call _save,$(DEVOPS_IMAGE),$(ARTIFACTS_IMAGES)/devops-astra-$(P)-v$(PROFILE_VERSION).tar)

test:
	$(call check_profile)
	$(call ensure)
	@echo "=== $(DEVOPS_IMAGE) ==="
	@$(call _run,$(DEVOPS_IMAGE),sh -c 'echo "--- release ---" && cat /etc/devops-release && echo "--- dpkg ---" && dpkg --version && echo "--- buildah ---" && buildah version && echo "--- git ---" && git --version && echo "--- gcc ---" && gcc --version | head -1 && echo "--- curl ---" && curl --version | head -1 && echo "--- go ---" && go version && echo "--- make ---" && make --version | head -1')

shell:
	$(call check_profile)
	$(call ensure)
	@$(call _shell,$(DEVOPS_IMAGE))

clean:
	$(call check_profile)
	@docker rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@buildah rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES) $(ARTIFACTS_DEPS)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) $* BACKEND=docker $(if $(P),P=$(P))

buildah/%:
	@$(MAKE) $* BACKEND=buildah $(if $(P),P=$(P))

# Catch-all: профиль как цель (например, make docker/image full)
$(PROFILES):
	@:

-include config.local.mk
-include config.mk

BASE_IMAGE        := astra-linux:2.12
include ../mk/versions.mk
GIT_VERSIONS := $(VERSIONS)

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

GIT_ARCHIVE_URL = $(GITHUB_URL)/git/git/archive/refs/tags

CU ?= $(CURL_VERSION)
ZL ?= $(ZLIB_VERSION)
OL ?= $(OPENSSL_VERSION)

# Имена файлов бинарных зависимостей
_CURL_DEP    = $(if $(CU),$(ARTIFACTS_DEPS)/curl-$(CU).tar.gz)
_ZLIB_DEP    = $(if $(ZL),$(ARTIFACTS_DEPS)/zlib-$(ZL).tar.gz)
_OPENSSL_DEP = $(if $(OL),$(ARTIFACTS_DEPS)/openssl-$(OL).tar.gz)

# Список активных deps
_ALL_DEPS = $(strip $(_CURL_DEP) $(_ZLIB_DEP) $(_OPENSSL_DEP))

include ../mk/backend.mk
include ../mk/deps.mk

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,curl,curl))
$(eval $(call dep_rule,zlib,zlib))
$(eval $(call dep_rule,openssl,openssl))

# --- Имена образов ---
image_name = git:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=git \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GIT_VERSION=$(V) \
	$(if $(CU),--build-arg CURL_VERSION=$(CU)) \
	$(if $(ZL),--build-arg ZLIB_VERSION=$(ZL)) \
	$(if $(OL),--build-arg OPENSSL_VERSION=$(OL))
_LABELS     = $(call labels,$(V))
_TAR_NAME   = git-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/bin/git && \
	ls -lh /out/usr/bin/git && \
	echo "=== version ===" && \
	/out/usr/bin/git --version && \
	echo "" && echo "git build: ok"'

# --- Валидация и ensure ---
check_version      = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 2.42.0)"; echo "Поддерживаемые версии: $(GIT_VERSIONS)"; exit 1; fi
check_src_file     = @test -f $(ARTIFACTS_SRC)/git-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/git-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)
ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean $(GIT_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники git (требует интернет)"
	@echo "  deps      X.Y.Z            Извлечь C-зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить git binary"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(GIT_VERSIONS)"
	@echo ""
	@echo "  Зависимости (deps):"
	@echo "    curl:<CU>-build            → artifacts/deps/"
	@echo "    zlib:<ZL>-build            → artifacts/deps/"
	@echo "    openssl:<OL>-build         → artifacts/deps/"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 2.42.0"
	@echo "    make docker/build 2.42.0"
	@echo "    make docker/test  2.42.0"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/git-$(V).tar.gz

$(ARTIFACTS_SRC)/git-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GIT_ARCHIVE_URL)/v$*.tar.gz

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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/git-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/git-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/git-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/git-$(V).tar.gz; \
	else \
	  for v in $(GIT_VERSIONS); do $(MAKE) clean V=$$v; done; \
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
$(GIT_VERSIONS):
	@:

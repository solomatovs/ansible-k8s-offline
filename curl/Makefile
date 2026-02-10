-include config.local.mk
-include config.mk

BASE_IMAGE        := astra-linux:2.12
include ../mk/versions.mk
CURL_VERSIONS := $(VERSIONS)

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_DEPS   := artifacts/deps
ARTIFACTS_BUILD  := artifacts/build
ARTIFACTS_IMAGES := artifacts/images

ZL ?= $(ZLIB_VERSION)
OL ?= $(OPENSSL_VERSION)
KR ?= $(KERBEROS_VERSION)
NH ?= $(NGHTTP2_VERSION)
OD ?= $(OPENLDAP_VERSION)
S2 ?= $(LIBSSH2_VERSION)
US ?= $(LIBUNISTRING_VERSION)
ID ?= $(LIBIDN2_VERSION)
ZS ?= $(ZSTD_VERSION)
BR ?= $(BROTLI_VERSION)
H3 ?= $(NGHTTP3_VERSION)
TC ?= $(NGTCP2_VERSION)

# Имена файлов бинарных зависимостей
_ZLIB_DEP         = $(if $(ZL),$(ARTIFACTS_DEPS)/zlib-$(ZL).tar.gz)
_OPENSSL_DEP      = $(if $(OL),$(ARTIFACTS_DEPS)/openssl-$(OL).tar.gz)
_KERBEROS_DEP     = $(if $(KR),$(ARTIFACTS_DEPS)/kerberos-$(KR).tar.gz)
_NGHTTP2_DEP      = $(if $(NH),$(ARTIFACTS_DEPS)/nghttp2-$(NH).tar.gz)
_OPENLDAP_DEP     = $(if $(OD),$(ARTIFACTS_DEPS)/openldap-$(OD).tar.gz)
_LIBSSH2_DEP      = $(if $(S2),$(ARTIFACTS_DEPS)/libssh2-$(S2).tar.gz)
_LIBUNISTRING_DEP = $(if $(US),$(ARTIFACTS_DEPS)/libunistring-$(US).tar.gz)
_LIBIDN2_DEP      = $(if $(ID),$(ARTIFACTS_DEPS)/libidn2-$(ID).tar.gz)
_ZSTD_DEP         = $(if $(ZS),$(ARTIFACTS_DEPS)/zstd-$(ZS).tar.gz)
_BROTLI_DEP       = $(if $(BR),$(ARTIFACTS_DEPS)/brotli-$(BR).tar.gz)
_NGHTTP3_DEP      = $(if $(H3),$(ARTIFACTS_DEPS)/nghttp3-$(H3).tar.gz)
_NGTCP2_DEP       = $(if $(TC),$(ARTIFACTS_DEPS)/ngtcp2-$(TC).tar.gz)

# Список активных deps
_ALL_DEPS = $(strip $(_ZLIB_DEP) $(_OPENSSL_DEP) $(_KERBEROS_DEP) $(_NGHTTP2_DEP) $(_OPENLDAP_DEP) $(_LIBSSH2_DEP) $(_LIBUNISTRING_DEP) $(_LIBIDN2_DEP) $(_ZSTD_DEP) $(_BROTLI_DEP) $(_NGHTTP3_DEP) $(_NGTCP2_DEP))

include ../mk/backend.mk
include ../mk/deps.mk

# Правила извлечения зависимостей из Docker-образов
$(eval $(call dep_rule,zlib,zlib))
$(eval $(call dep_rule,openssl,openssl))
$(eval $(call dep_rule,kerberos,kerberos))
$(eval $(call dep_rule,nghttp2,nghttp2))
$(eval $(call dep_rule,openldap,openldap))
$(eval $(call dep_rule,libssh2,libssh2))
$(eval $(call dep_rule,libunistring,libunistring))
$(eval $(call dep_rule,libidn2,libidn2))
$(eval $(call dep_rule,zstd,zstd))
$(eval $(call dep_rule,brotli,brotli))
$(eval $(call dep_rule,nghttp3,nghttp3))
$(eval $(call dep_rule,ngtcp2,ngtcp2))

# --- Имена образов ---
image_name = curl:$(1)-build

# --- OCI-лейблы ---
labels = \
	--label org.opencontainers.image.title=curl \
	--label org.opencontainers.image.version=$(1)-build \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# --- Вычисляемые переменные ---
_IMAGE      = $(call image_name,$(V))
_BUILD_ARGS = \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg CURL_VERSION=$(V) \
	$(if $(ZL),--build-arg ZLIB_VERSION=$(ZL)) \
	$(if $(OL),--build-arg OPENSSL_VERSION=$(OL)) \
	$(if $(KR),--build-arg KERBEROS_VERSION=$(KR)) \
	$(if $(NH),--build-arg NGHTTP2_VERSION=$(NH)) \
	$(if $(OD),--build-arg OPENLDAP_VERSION=$(OD)) \
	$(if $(S2),--build-arg LIBSSH2_VERSION=$(S2)) \
	$(if $(US),--build-arg LIBUNISTRING_VERSION=$(US)) \
	$(if $(ID),--build-arg LIBIDN2_VERSION=$(ID)) \
	$(if $(ZS),--build-arg ZSTD_VERSION=$(ZS)) \
	$(if $(BR),--build-arg BROTLI_VERSION=$(BR)) \
	$(if $(H3),--build-arg NGHTTP3_VERSION=$(H3)) \
	$(if $(TC),--build-arg NGTCP2_VERSION=$(TC))
_LABELS     = $(call labels,$(V))
_TAR_NAME   = curl-$(V)-build.tar
_TEST_CMD   = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcurl.a && \
	test -f /out/usr/include/curl/curl.h && \
	test -f /out/usr/bin/curl && \
	ls -lh /out/usr/lib/libcurl.a && \
	echo "=== shared libraries ===" && \
	find /out -name "libcurl*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libcurl.pc && \
	echo "" && echo "curl build: ok"'

# --- Валидация и ensure ---
check_version      = @if [ -z "$(V)" ]; then echo "Ошибка: укажите версию (например, make docker/image 8.4.0)"; echo "Поддерживаемые версии: $(CURL_VERSIONS)"; exit 1; fi
check_src_file     = @test -f $(ARTIFACTS_SRC)/curl-$(V).tar.gz || (echo "Ошибка: $(ARTIFACTS_SRC)/curl-$(V).tar.gz не найден"; echo "Выполните: make download $(V)"; exit 1)
ensure = @$(call _ensure_check,$(call image_name,$(1))) $(MAKE) image V=$(1)

.DEFAULT_GOAL := help

.PHONY: help download deps image build test shell clean $(CURL_VERSIONS)

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  download  X.Y.Z            Скачать исходники curl (требует интернет)"
	@echo "  deps      X.Y.Z            Извлечь C-зависимости из Docker-образов в artifacts/deps/"
	@echo "  image     X.Y.Z            Собрать образ и экспортировать в artifacts/images/"
	@echo "  build     X.Y.Z            Архивировать артефакты в artifacts/build/"
	@echo "  test      X.Y.Z            Проверить libcurl.a и заголовки"
	@echo "  shell     X.Y.Z            Shell в образе"
	@echo "  clean     X.Y.Z            Удалить образы и артефакты версии"
	@echo "  clean                      Удалить все образы и артефакты"
	@echo ""
	@echo "  Поддерживаемые версии: $(CURL_VERSIONS)"
	@echo ""
	@echo "  Зависимости (deps):"
	@echo "    zlib:<ZL>-build            → artifacts/deps/"
	@echo "    openssl:<OL>-build         → artifacts/deps/"
	@echo "    kerberos:<KR>-build        → artifacts/deps/"
	@echo "    nghttp2:<NH>-build         → artifacts/deps/"
	@echo "    openldap:<OD>-build        → artifacts/deps/"
	@echo "    libssh2:<S2>-build         → artifacts/deps/"
	@echo "    libunistring:<US>-build    → artifacts/deps/"
	@echo "    libidn2:<ID>-build         → artifacts/deps/"
	@echo "    zstd:<ZS>-build            → artifacts/deps/"
	@echo "    brotli:<BR>-build          → artifacts/deps/"
	@echo "    nghttp3:<H3>-build         → artifacts/deps/"
	@echo "    ngtcp2:<TC>-build          → artifacts/deps/"
	@echo ""
	@echo "  Примеры:"
	@echo "    make docker/image 8.4.0"
	@echo "    make docker/build 8.4.0"
	@echo "    make docker/test  8.4.0"

# --- Скачивание исходников ---
download:
	$(call check_version)
	@$(MAKE) $(ARTIFACTS_SRC)/curl-$(V).tar.gz

$(ARTIFACTS_SRC)/curl-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(CURL_URL)/curl-$*.tar.gz

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
	@$(call _extract,$(call image_name,$(V)),$(ARTIFACTS_BUILD)/curl-$(V).tar.gz)

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
	  rm -f $(ARTIFACTS_IMAGES)/curl-$(V)-build.tar; \
	  rm -f $(ARTIFACTS_BUILD)/curl-$(V).tar.gz; \
	  rm -f $(ARTIFACTS_SRC)/curl-$(V).tar.gz; \
	else \
	  for v in $(CURL_VERSIONS); do $(MAKE) clean V=$$v; done; \
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
$(CURL_VERSIONS):
	@:

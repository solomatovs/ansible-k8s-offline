-include config.local.mk
-include config.mk

PROJECT    := git
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/git-$(V).tar.gz

_DEPS = curl:CU:CURL_VERSION \
        zlib:ZL:ZLIB_VERSION \
        openssl:OL:OPENSSL_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/bin/git && \
	ls -lh /out/usr/bin/git && \
	echo "=== version ===" && \
	/out/usr/bin/git --version && \
	echo "" && echo "git build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/git-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/git/git/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

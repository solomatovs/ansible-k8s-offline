-include config.local.mk
-include config.mk

PROJECT    := brotli
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/brotli-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libbrotlidec.a && \
	test -f /out/usr/lib/libbrotlienc.a && \
	test -f /out/usr/lib/libbrotlicommon.a && \
	ls -lh /out/usr/lib/libbrotli*.a && \
	echo "=== shared libraries ===" && \
	find /out -name "libbrotli*.so*" -exec ls -lh {} \; && \
	echo "" && echo "brotli build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/brotli-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/google/brotli/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

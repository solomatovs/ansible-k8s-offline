-include config.local.mk
-include config.mk

PROJECT    := nghttp3
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/nghttp3-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libnghttp3.a && \
	ls -lh /out/usr/lib/libnghttp3.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libnghttp3.pc && \
	echo "" && echo "nghttp3 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/nghttp3-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/ngtcp2/nghttp3/releases/download/v$*/nghttp3-$*.tar.gz

include ../mk/project.mk

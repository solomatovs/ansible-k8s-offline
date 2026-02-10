-include config.local.mk
-include config.mk

PROJECT    := nghttp2
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/nghttp2-$(V).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libnghttp2.a && \
	ls -lh /out/usr/lib/libnghttp2.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libnghttp2.pc && \
	echo "" && echo "nghttp2 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/nghttp2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/nghttp2/nghttp2/releases/download/v$*/nghttp2-$*.tar.gz

include ../mk/project.mk

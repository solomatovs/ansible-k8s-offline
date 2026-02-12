-include config.local.mk
-include config.mk

PROJECT    := zlib
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/zlib-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libz.a && \
	test -f /out/usr/include/zlib.h && \
	ls -lh /out/usr/lib/libz.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/zlib.pc && \
	echo "" && echo "zlib build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/zlib-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(ZLIB_URL)/zlib-$*.tar.gz

include ../mk/project.mk

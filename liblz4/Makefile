-include config.local.mk
-include config.mk

PROJECT     := liblz4
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := LZ4_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/lz4-$(V).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/liblz4.a && \
	test -f /out/usr/include/lz4.h && \
	test -f /out/usr/lib/pkgconfig/liblz4.pc && \
	ls -lh /out/usr/lib/liblz4.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/liblz4.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/liblz4.pc && \
	echo "" && echo "liblz4 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/lz4-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/lz4/lz4/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

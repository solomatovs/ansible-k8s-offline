-include config.local.mk
-include config.mk

PROJECT     := liblzma
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := LZMA_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/xz-$(V).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/liblzma.a && \
	test -f /out/usr/include/lzma.h && \
	test -f /out/usr/lib/pkgconfig/liblzma.pc && \
	ls -lh /out/usr/lib/liblzma.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/liblzma.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/liblzma.pc && \
	echo "" && echo "liblzma build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/xz-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(XZ_MIRROR)/xz-$*.tar.gz

include ../mk/project.mk

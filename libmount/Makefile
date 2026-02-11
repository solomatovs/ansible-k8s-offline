-include config.local.mk
-include config.mk

PROJECT     := libmount
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := UTIL_LINUX_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/util-linux-$(V).tar.gz

# Зависимости: bison
_DEPS = bison:BI:BISON_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libmount.a && \
	test -f /out/usr/lib/libblkid.a && \
	test -f /out/usr/lib/libuuid.a && \
	test -f /out/usr/lib/pkgconfig/mount.pc && \
	test -f /out/usr/lib/pkgconfig/blkid.pc && \
	test -f /out/usr/lib/pkgconfig/uuid.pc && \
	ls -lh /out/usr/lib/libmount.a /out/usr/lib/libblkid.a /out/usr/lib/libuuid.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libmount.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/mount.pc && \
	echo "" && echo "libmount build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/util-linux-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/util-linux/util-linux/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

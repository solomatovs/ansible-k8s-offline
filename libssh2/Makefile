-include config.local.mk
-include config.mk

PROJECT    := libssh2
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libssh2-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libssh2.a && \
	test -f /out/usr/include/libssh2.h && \
	ls -lh /out/usr/lib/libssh2.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libssh2.pc && \
	echo "" && echo "libssh2 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libssh2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/libssh2/libssh2/releases/download/libssh2-$*/libssh2-$*.tar.gz

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT     := libgpg-error
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := GPG_ERROR_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libgpg-error-$(V).tar.bz2

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libgpg-error.a && \
	test -f /out/usr/include/gpg-error.h && \
	ls -lh /out/usr/lib/libgpg-error.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libgpg-error.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libgpg-error build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libgpg-error-%.tar.bz2:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNUPG_FTP_URL)/libgpg-error/libgpg-error-$*.tar.bz2

include ../mk/project.mk

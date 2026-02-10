-include config.local.mk
-include config.mk

PROJECT     := libgcrypt
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := GCRYPT_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libgcrypt-$(V).tar.bz2

_DEPS = libgpg-error:GE:GPG_ERROR_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libgcrypt.a && \
	test -f /out/usr/include/gcrypt.h && \
	ls -lh /out/usr/lib/libgcrypt.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libgcrypt.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libgcrypt build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libgcrypt-%.tar.bz2:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNUPG_FTP_URL)/libgcrypt/libgcrypt-$*.tar.bz2

include ../mk/project.mk

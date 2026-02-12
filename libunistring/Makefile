-include config.local.mk
-include config.mk

PROJECT    := libunistring
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libunistring-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libunistring.a && \
	test -f /out/usr/include/unistr.h && \
	ls -lh /out/usr/lib/libunistring.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libunistring build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libunistring-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_FTP_URL)/libunistring/libunistring-$*.tar.gz

include ../mk/project.mk

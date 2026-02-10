-include config.local.mk
-include config.mk

PROJECT    := libidn2
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libidn2-$(V).tar.gz

_DEPS = libunistring:US:LIBUNISTRING_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libidn2.a && \
	test -f /out/usr/include/idn2.h && \
	ls -lh /out/usr/lib/libidn2.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libidn2.pc && \
	echo "" && echo "libidn2 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libidn2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_FTP_URL)/libidn/libidn2-$*.tar.gz

include ../mk/project.mk

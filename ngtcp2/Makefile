-include config.local.mk
-include config.mk

PROJECT    := ngtcp2
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/ngtcp2-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libngtcp2.a && \
	ls -lh /out/usr/lib/libngtcp2*.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libngtcp2.pc && \
	echo "" && echo "ngtcp2 build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/ngtcp2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/ngtcp2/ngtcp2/releases/download/v$*/ngtcp2-$*.tar.gz

include ../mk/project.mk

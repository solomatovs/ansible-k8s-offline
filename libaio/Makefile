-include config.local.mk
-include config.mk

PROJECT    := libaio
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libaio-$(V).tar.gz

_TEST_CMD = sh -c '\
	test -f /out/usr/include/libaio.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libaio.a && \
	echo "libaio $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libaio-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/$(LIBAIO_REPO)/archive/refs/tags/libaio-$*.tar.gz

include ../mk/project.mk

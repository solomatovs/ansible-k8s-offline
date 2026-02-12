-include config.local.mk
-include config.mk

PROJECT    := lzo
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/lzo-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	test -f /out/usr/include/lzo/lzo1x.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/liblzo2.so && \
	echo "lzo $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/lzo-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(LZO_URL)/lzo-$*.tar.gz

include ../mk/project.mk

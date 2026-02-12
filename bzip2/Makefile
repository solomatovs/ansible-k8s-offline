-include config.local.mk
-include config.mk

PROJECT    := bzip2
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/bzip2-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	test -f /out/usr/include/bzlib.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libbz2.a && \
	echo "bzip2 $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/bzip2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SOURCEWARE_URL)/bzip2/bzip2-$*.tar.gz

include ../mk/project.mk

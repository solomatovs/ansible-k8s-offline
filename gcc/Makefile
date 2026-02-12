-include config.local.mk
-include config.mk

PROJECT    := gcc
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/gcc-$(PF_VERSION).tar.xz

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gcc && \
	test -f /out/usr/bin/g++ && \
	echo "gcc $(PF_VERSION): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/gcc-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/gcc/gcc-$*/gcc-$*.tar.xz

include ../mk/project.mk

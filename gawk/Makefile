-include config.local.mk
-include config.mk

PROJECT    := gawk
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/gawk-$(PF_VERSION).tar.xz

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gawk && \
	echo "gawk $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/gawk-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/gawk/gawk-$*.tar.xz

include ../mk/project.mk

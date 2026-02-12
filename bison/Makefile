-include config.local.mk
-include config.mk

PROJECT    := bison
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/bison-$(PF_VERSION).tar.xz

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/bison && \
	echo "bison $(PF_VERSION): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/bison-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/bison/bison-$*.tar.xz

include ../mk/project.mk

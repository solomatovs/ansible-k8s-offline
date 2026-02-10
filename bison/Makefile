-include config.local.mk
-include config.mk

PROJECT    := bison
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/bison-$(V).tar.xz

_EXTRA_SRC_FILES = $(if $(M4_VERSION),$(ARTIFACTS_SRC)/m4-$(M4_VERSION).tar.xz)
_EXTRA_BUILD_ARGS = $(if $(M4_VERSION),--build-arg M4_VERSION=$(M4_VERSION))

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/bison && \
	test -f /out/usr/bin/m4 && \
	echo "bison $(V) + m4 $(M4_VERSION): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/bison-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/bison/bison-$*.tar.xz

$(ARTIFACTS_SRC)/m4-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/m4/m4-$*.tar.xz

include ../mk/project.mk

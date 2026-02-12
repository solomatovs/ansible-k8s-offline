-include config.local.mk
-include config.mk

PROJECT    := pcre
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/pcre-$(PF_VERSION).tar.bz2

_TEST_CMD = sh -c '\
	test -f /out/usr/include/pcre.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libpcre.so && \
	echo "pcre $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/pcre-%.tar.bz2:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -L -o $@ $(PCRE_URL)/$*/pcre-$*.tar.bz2/download

include ../mk/project.mk

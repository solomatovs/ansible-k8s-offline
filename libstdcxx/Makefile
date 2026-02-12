-include config.local.mk
-include config.mk

PROJECT    := libstdcxx
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/gcc-$(PF_VERSION).tar.xz

_TEST_CMD = sh -c '\
	test -f /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
	test -f /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.25 && \
	echo "libstdc++ 6.0.25 (GLIBCXX_3.4.25): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/gcc-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/gcc/gcc-$*/gcc-$*.tar.xz

include ../mk/project.mk

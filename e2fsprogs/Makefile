-include config.local.mk
-include config.mk

PROJECT    := e2fsprogs
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/e2fsprogs-$(V).tar.gz

_TEST_CMD = sh -c '\
	test -f /out/usr/include/ext2fs/ext2fs.h && \
	test -f /out/usr/lib/libext2fs.a && \
	echo "e2fsprogs $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/e2fsprogs-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/tytso/e2fsprogs/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT     := libudev
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := SYSTEMD_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/systemd-$(V).tar.gz

_DEPS = libcap:LC:LIBCAP_VERSION

_TEST_CMD = sh -c '\
	test -f /out/usr/include/libudev.h && \
	test -f /out/usr/lib/libudev.a && \
	echo "libudev (systemd $(V)): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/systemd-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/systemd/systemd/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

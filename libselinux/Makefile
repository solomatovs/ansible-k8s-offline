-include config.local.mk
-include config.mk

PROJECT     := libselinux
BASE_IMAGE  := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libselinux-$(PF_VERSION).tar.gz

SP ?= $(SEPOL_VERSION)

_EXTRA_BUILD_ARGS  = $(if $(SP),--build-arg SEPOL_VERSION=$(SP)) $(if $(PCRE_VERSION),--build-arg PCRE_VERSION=$(PCRE_VERSION))
_EXTRA_SRC_FILES   = $(if $(SP),$(ARTIFACTS_SRC)/libsepol-$(SP).tar.gz)
_EXTRA_CLEAN_FILES = $(if $(SP),$(ARTIFACTS_SRC)/libsepol-$(SP).tar.gz)

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libselinux.a && \
	test -f /out/usr/lib/libsepol.a && \
	test -f /out/usr/include/selinux/selinux.h && \
	ls -lh /out/usr/lib/libselinux.a /out/usr/lib/libsepol.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libselinux.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libselinux.pc && \
	echo "" && echo "libselinux build: ok"'

# --- Скачивание исходников ---
SELINUX_ARCHIVE_URL = $(GITHUB_URL)/SELinuxProject/selinux/archive/refs/tags

$(ARTIFACTS_SRC)/libselinux-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SELINUX_ARCHIVE_URL)/libselinux-$*.tar.gz

$(ARTIFACTS_SRC)/libsepol-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(SELINUX_ARCHIVE_URL)/libsepol-$*.tar.gz

include ../mk/project.mk

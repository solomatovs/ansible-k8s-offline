-include config.local.mk
-include config.mk

PROJECT       := libselinux
BASE_IMAGE    := astra-linux:2.12
ARTIFACTS_SRC ?= artifacts/src

SP ?= $(SEPOL_VERSION)

_EXTRA_BUILD_ARGS  = $(if $(SP),--build-arg SEPOL_VERSION=$(SP))
_EXTRA_SRC_FILES   = $(if $(SP),$(ARTIFACTS_SRC)/libsepol-$(SP).tar.gz)
_EXTRA_URLS_CMD    = $(if $(SP),echo "$(LIBSELINUX_SRC_URL)/archive/refs/tags/libsepol-$(SP).tar.gz $(PROJECT)/$(ARTIFACTS_SRC) libsepol-$(SP).tar.gz";)
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

$(ARTIFACTS_SRC)/libsepol-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(LIBSELINUX_SRC_URL)/archive/refs/tags/libsepol-$*.tar.gz

include ../mk/project.mk

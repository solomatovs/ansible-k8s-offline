-include config.local.mk
-include config.mk

PROJECT     := libdevmapper
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := LVM2_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/lvm2-$(V).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libdevmapper.a && \
	test -f /out/usr/include/libdevmapper.h && \
	test -f /out/usr/lib/pkgconfig/devmapper.pc && \
	ls -lh /out/usr/lib/libdevmapper.a && \
	echo "=== file type ===" && \
	file /out/usr/lib/libdevmapper.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/devmapper.pc && \
	echo "" && echo "libdevmapper build: ok"'

# --- Скачивание исходников ---
# LVM2 использует формат тегов v2_03_25 (подчёркивания вместо точек)
$(ARTIFACTS_SRC)/lvm2-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/lvmteam/lvm2/archive/refs/tags/v$(subst .,_,$*).tar.gz

include ../mk/project.mk

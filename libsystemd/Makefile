-include config.local.mk
-include config.mk

PROJECT     := libsystemd
BASE_IMAGE  := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/systemd-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libsystemd.a && \
	test -f /out/usr/include/systemd/sd-journal.h && \
	test -f /out/usr/lib/pkgconfig/libsystemd.pc && \
	ls -lh /out/usr/lib/libsystemd.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libsystemd.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libsystemd.pc && \
	echo "" && echo "libsystemd build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/systemd-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/systemd/systemd/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

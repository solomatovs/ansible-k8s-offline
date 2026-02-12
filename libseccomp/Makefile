-include config.local.mk
-include config.mk

PROJECT     := libseccomp
BASE_IMAGE  := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libseccomp-$(PF_VERSION).tar.gz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libseccomp.a && \
	test -f /out/usr/include/seccomp.h && \
	test -f /out/usr/lib/pkgconfig/libseccomp.pc && \
	ls -lh /out/usr/lib/libseccomp.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libseccomp.pc && \
	echo "" && echo "libseccomp build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libseccomp-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/seccomp/libseccomp/releases/download/v$*/libseccomp-$*.tar.gz

include ../mk/project.mk

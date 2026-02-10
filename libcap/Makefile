-include config.local.mk
-include config.mk

PROJECT    := libcap
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/libcap-$(V).tar.xz

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcap.a && \
	test -f /out/usr/include/sys/capability.h && \
	ls -lh /out/usr/lib/libcap.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libcap.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libcap build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/libcap-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(KERNEL_URL)/linux/libs/security/linux-privs/libcap2/libcap-$*.tar.xz

include ../mk/project.mk

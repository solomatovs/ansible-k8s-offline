-include config.local.mk
-include config.mk

PROJECT     := libgcrypt
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libgcrypt.a && \
	test -f /out/usr/include/gcrypt.h && \
	ls -lh /out/usr/lib/libgcrypt.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libgcrypt.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libgcrypt build: ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT     := libgpg-error
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libgpg-error.a && \
	test -f /out/usr/include/gpg-error.h && \
	ls -lh /out/usr/lib/libgpg-error.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libgpg-error.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libgpg-error build: ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := libmd
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libmd.a && \
	test -f /out/usr/include/md5.h && \
	ls -lh /out/usr/lib/libmd.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libmd build: ok"'

include ../mk/project.mk

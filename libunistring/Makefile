-include config.local.mk
-include config.mk

PROJECT    := libunistring
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libunistring.a && \
	test -f /out/usr/include/unistr.h && \
	ls -lh /out/usr/lib/libunistring.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libunistring build: ok"'

include ../mk/project.mk

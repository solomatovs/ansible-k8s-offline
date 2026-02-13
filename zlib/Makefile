-include config.local.mk
-include config.mk

PROJECT    := zlib
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libz.a && \
	test -f /out/usr/include/zlib.h && \
	ls -lh /out/usr/lib/libz.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/zlib.pc && \
	echo "" && echo "zlib build: ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := zstd
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libzstd.a && \
	test -f /out/usr/include/zstd.h && \
	ls -lh /out/usr/lib/libzstd.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libzstd.pc && \
	echo "" && echo "zstd build: ok"'

include ../mk/project.mk

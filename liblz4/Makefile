-include config.local.mk
-include config.mk

PROJECT     := liblz4
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/liblz4.a && \
	test -f /out/usr/include/lz4.h && \
	test -f /out/usr/lib/pkgconfig/liblz4.pc && \
	ls -lh /out/usr/lib/liblz4.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/liblz4.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/liblz4.pc && \
	echo "" && echo "liblz4 build: ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := ngtcp2
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libngtcp2.a && \
	ls -lh /out/usr/lib/libngtcp2*.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libngtcp2.pc && \
	echo "" && echo "ngtcp2 build: ok"'

include ../mk/project.mk

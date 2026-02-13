-include config.local.mk
-include config.mk

PROJECT    := libidn2
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libidn2.a && \
	test -f /out/usr/include/idn2.h && \
	ls -lh /out/usr/lib/libidn2.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libidn2.pc && \
	echo "" && echo "libidn2 build: ok"'

include ../mk/project.mk

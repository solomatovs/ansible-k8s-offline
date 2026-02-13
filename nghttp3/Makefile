-include config.local.mk
-include config.mk

PROJECT    := nghttp3
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libnghttp3.a && \
	ls -lh /out/usr/lib/libnghttp3.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libnghttp3.pc && \
	echo "" && echo "nghttp3 build: ok"'

include ../mk/project.mk

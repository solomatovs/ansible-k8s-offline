-include config.local.mk
-include config.mk

PROJECT    := curl
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcurl.a && \
	test -f /out/usr/include/curl/curl.h && \
	test -f /out/usr/bin/curl && \
	ls -lh /out/usr/lib/libcurl.a && \
	echo "=== shared libraries ===" && \
	find /out -name "libcurl*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libcurl.pc && \
	echo "" && echo "curl build: ok"'

include ../mk/project.mk

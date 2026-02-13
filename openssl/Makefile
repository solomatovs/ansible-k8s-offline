-include config.local.mk
-include config.mk

PROJECT    := openssl
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libssl.a && \
	test -f /out/usr/lib/libcrypto.a && \
	test -f /out/usr/include/openssl/ssl.h && \
	ls -lh /out/usr/lib/libssl.a /out/usr/lib/libcrypto.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/openssl.pc && \
	echo "" && echo "openssl build: ok"'

include ../mk/project.mk

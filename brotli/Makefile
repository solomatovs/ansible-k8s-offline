-include config.local.mk
-include config.mk

PROJECT    := brotli
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libbrotlidec.a && \
	test -f /out/usr/lib/libbrotlienc.a && \
	test -f /out/usr/lib/libbrotlicommon.a && \
	ls -lh /out/usr/lib/libbrotli*.a && \
	echo "=== shared libraries ===" && \
	find /out -name "libbrotli*.so*" -exec ls -lh {} \; && \
	echo "" && echo "brotli build: ok"'

include ../mk/project.mk

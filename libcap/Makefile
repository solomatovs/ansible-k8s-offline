-include config.local.mk
-include config.mk

PROJECT    := libcap
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcap.a && \
	test -f /out/usr/include/sys/capability.h && \
	ls -lh /out/usr/lib/libcap.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libcap.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libcap build: ok"'

include ../mk/project.mk

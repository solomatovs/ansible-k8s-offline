-include config.local.mk
-include config.mk

PROJECT     := libdevmapper
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libdevmapper.a && \
	test -f /out/usr/include/libdevmapper.h && \
	test -f /out/usr/lib/pkgconfig/devmapper.pc && \
	ls -lh /out/usr/lib/libdevmapper.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libdevmapper.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/devmapper.pc && \
	echo "" && echo "libdevmapper build: ok"'

include ../mk/project.mk

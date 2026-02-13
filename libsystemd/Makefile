-include config.local.mk
-include config.mk

PROJECT     := libsystemd
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libsystemd.a && \
	test -f /out/usr/include/systemd/sd-journal.h && \
	test -f /out/usr/lib/pkgconfig/libsystemd.pc && \
	ls -lh /out/usr/lib/libsystemd.a && \
	echo "=== file type ===" && \
	head -c 7 /out/usr/lib/libsystemd.a && echo "" && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libsystemd.pc && \
	echo "" && echo "libsystemd build: ok"'

include ../mk/project.mk

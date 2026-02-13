-include config.local.mk
-include config.mk

PROJECT     := libseccomp
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libseccomp.a && \
	test -f /out/usr/include/seccomp.h && \
	test -f /out/usr/lib/pkgconfig/libseccomp.pc && \
	ls -lh /out/usr/lib/libseccomp.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libseccomp.pc && \
	echo "" && echo "libseccomp build: ok"'

include ../mk/project.mk

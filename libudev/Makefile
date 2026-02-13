-include config.local.mk
-include config.mk

PROJECT     := libudev
BASE_IMAGE  := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/libudev.h && \
	test -f /out/usr/lib/libudev.a && \
	echo "libudev (systemd $(V)): ok"'

include ../mk/project.mk

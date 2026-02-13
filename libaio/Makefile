-include config.local.mk
-include config.mk

PROJECT    := libaio
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/libaio.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libaio.a && \
	echo "libaio $(V): ok"'

include ../mk/project.mk

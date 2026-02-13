-include config.local.mk
-include config.mk

PROJECT    := lzo
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/lzo/lzo1x.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/liblzo2.so && \
	echo "lzo $(V): ok"'

include ../mk/project.mk

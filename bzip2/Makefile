-include config.local.mk
-include config.mk

PROJECT    := bzip2
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/bzlib.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libbz2.a && \
	echo "bzip2 $(V): ok"'

include ../mk/project.mk

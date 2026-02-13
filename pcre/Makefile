-include config.local.mk
-include config.mk

PROJECT    := pcre
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/pcre.h && \
	test -f /out/usr/lib/x86_64-linux-gnu/libpcre.so && \
	echo "pcre $(V): ok"'

include ../mk/project.mk

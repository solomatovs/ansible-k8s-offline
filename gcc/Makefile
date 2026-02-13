-include config.local.mk
-include config.mk

PROJECT    := gcc
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gcc && \
	test -f /out/usr/bin/g++ && \
	echo "gcc $(PF_VERSION): ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := gawk
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gawk && \
	echo "gawk $(V): ok"'

include ../mk/project.mk

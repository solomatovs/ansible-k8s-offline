-include config.local.mk
-include config.mk

PROJECT    := bison
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/bison && \
	echo "bison $(PF_VERSION): ok"'

include ../mk/project.mk

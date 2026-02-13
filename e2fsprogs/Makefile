-include config.local.mk
-include config.mk

PROJECT    := e2fsprogs
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/include/ext2fs/ext2fs.h && \
	test -f /out/usr/lib/libext2fs.a && \
	echo "e2fsprogs $(V): ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := git
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/bin/git && \
	ls -lh /out/usr/bin/git && \
	echo "=== version ===" && \
	/out/usr/bin/git --version && \
	echo "" && echo "git build: ok"'

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := dpkg
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/bin/dpkg && \
	test -f /out/usr/bin/dpkg-deb && \
	test -f /out/usr/bin/dpkg-query && \
	ls -lh /out/usr/bin/dpkg /out/usr/bin/dpkg-deb /out/usr/bin/dpkg-query && \
	echo "=== static check ===" && \
	file /out/usr/bin/dpkg && \
	echo "" && echo "dpkg build: ok"'

include ../mk/project.mk

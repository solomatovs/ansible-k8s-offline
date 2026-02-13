-include config.local.mk
-include config.mk

PROJECT    := libstdcxx
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
	test -f /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.25 && \
	echo "libstdc++ 6.0.25 (GLIBCXX_3.4.25): ok"'

include ../mk/project.mk

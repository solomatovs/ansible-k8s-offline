-include config.local.mk
-include config.mk

PROJECT    := openldap
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libldap.a && \
	test -f /out/usr/lib/liblber.a && \
	test -f /out/usr/include/ldap.h && \
	ls -lh /out/usr/lib/libldap.a /out/usr/lib/liblber.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "openldap build: ok"'

include ../mk/project.mk

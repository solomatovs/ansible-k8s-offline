-include config.local.mk
-include config.mk

PROJECT    := kerberos
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== static libraries ===" && \
	test -f /out/usr/lib/libgssapi_krb5.a && \
	test -f /out/usr/lib/libkrb5.a && \
	ls -lh /out/usr/lib/*.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "=== headers ===" && \
	test -f /out/usr/include/krb5/krb5.h && \
	echo "krb5.h: ok" && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/krb5.pc 2>/dev/null || echo "no krb5.pc" && \
	echo "" && echo "kerberos build: ok"'

include ../mk/project.mk

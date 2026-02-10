-include config.local.mk
-include config.mk

PROJECT    := openldap
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/openldap-$(V).tgz

_DEPS = openssl:OL:OPENSSL_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libldap.a && \
	test -f /out/usr/lib/liblber.a && \
	test -f /out/usr/include/ldap.h && \
	ls -lh /out/usr/lib/libldap.a /out/usr/lib/liblber.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "openldap build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/openldap-%.tgz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(OPENLDAP_URL)/openldap-$*.tgz

include ../mk/project.mk

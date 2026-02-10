-include config.local.mk
-include config.mk

PROJECT    := curl
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/curl-$(V).tar.gz

_DEPS = zlib:ZL:ZLIB_VERSION \
        openssl:OL:OPENSSL_VERSION \
        kerberos:KR:KERBEROS_VERSION \
        nghttp2:NH:NGHTTP2_VERSION \
        openldap:OD:OPENLDAP_VERSION \
        libssh2:S2:LIBSSH2_VERSION \
        libunistring:US:LIBUNISTRING_VERSION \
        libidn2:ID:LIBIDN2_VERSION \
        zstd:ZS:ZSTD_VERSION \
        brotli:BR:BROTLI_VERSION \
        nghttp3:H3:NGHTTP3_VERSION \
        ngtcp2:TC:NGTCP2_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libcurl.a && \
	test -f /out/usr/include/curl/curl.h && \
	test -f /out/usr/bin/curl && \
	ls -lh /out/usr/lib/libcurl.a && \
	echo "=== shared libraries ===" && \
	find /out -name "libcurl*.so*" -exec ls -lh {} \; && \
	echo "=== pkg-config ===" && \
	cat /out/usr/lib/pkgconfig/libcurl.pc && \
	echo "" && echo "curl build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/curl-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(CURL_URL)/curl-$*.tar.gz

include ../mk/project.mk

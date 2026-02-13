PF_VERSION    = 2.42.0
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 zlib:1.3.1 brotli:1.1.0 zstd:1.5.5 nghttp2:1.58.0 nghttp3:1.1.0 ngtcp2:1.2.0 libunistring:1.1 libidn2:2.3.4 bison:3.8.2 openssl:1.1.1w kerberos:1.20.1 openldap:2.6.6 libssh2:1.11.0 curl:8.4.0

PF_SRC_URL    = $(GIT_SRC_URL)/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = git-$(PF_VERSION).tar.gz

PF_VERSION    = 8.4.0
PF_TOOLCHAIN  = toolchain-gcc:8.5.0-r1
PF_DEPS       = zlib:1.3.1-r1 openssl:1.1.1w-r1 kerberos:1.20.1-r1 \
                nghttp2:1.58.0-r1 openldap:2.6.6-r1 libssh2:1.11.0-r1 \
                libunistring:1.1-r1 libidn2:2.3.4-r1 zstd:1.5.5-r1 \
                brotli:1.1.0-r1 nghttp3:1.1.0-r1 ngtcp2:1.2.0-r1
PF_DOCKERFILE = Dockerfile

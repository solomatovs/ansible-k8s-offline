PF_VERSION    = full
PF_DEPS       = glibc:2.28 libstdcxx:8.5.0 gcc:8.5.0 \
                zlib:1.3.1 openssl:1.1.1w kerberos:1.20.1 \
                nghttp2:1.58.0 openldap:2.6.6 libssh2:1.11.0 \
                libunistring:1.1 libidn2:2.3.4 zstd:1.5.5 \
                brotli:1.1.0 nghttp3:1.1.0 ngtcp2:1.2.0 \
                curl:8.4.0 dpkg:1.23.5 \
                buildah:1.38.0 git:2.42.0 golang:1.24.5
PF_DOCKERFILE = Dockerfile

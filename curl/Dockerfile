# Сборка статической и динамической библиотеки curl из исходников.
# Все C-зависимости подаются как файловые зависимости из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libcurl.a             — статическая библиотека
#   /out/usr/lib/libcurl.so*           — динамическая библиотека
#   /out/usr/include/curl/*.h          — заголовочные файлы
#   /out/usr/lib/pkgconfig/libcurl.pc  — pkg-config
#   /out/usr/bin/curl                  — CLI
# Использование: COPY --from=curl:8.4.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG CURL_VERSION=8.4.0
ARG ZLIB_VERSION=1.3.1
ARG OPENSSL_VERSION=1.1.1w
ARG KERBEROS_VERSION=1.20.1
ARG NGHTTP2_VERSION=1.58.0
ARG OPENLDAP_VERSION=2.6.6
ARG LIBSSH2_VERSION=1.11.0
ARG LIBUNISTRING_VERSION=1.1
ARG LIBIDN2_VERSION=2.3.4
ARG ZSTD_VERSION=1.5.5
ARG BROTLI_VERSION=1.1.0
ARG NGHTTP3_VERSION=1.1.0
ARG NGTCP2_VERSION=1.2.0

# C-зависимости для сборки (make deps)
COPY artifacts/deps/zlib-${ZLIB_VERSION}.tar.gz /build/
RUN tar xzf /build/zlib-${ZLIB_VERSION}.tar.gz -C / \
 && rm /build/zlib-${ZLIB_VERSION}.tar.gz

COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

COPY artifacts/deps/kerberos-${KERBEROS_VERSION}.tar.gz /build/
RUN tar xzf /build/kerberos-${KERBEROS_VERSION}.tar.gz -C / \
 && rm /build/kerberos-${KERBEROS_VERSION}.tar.gz

COPY artifacts/deps/nghttp2-${NGHTTP2_VERSION}.tar.gz /build/
RUN tar xzf /build/nghttp2-${NGHTTP2_VERSION}.tar.gz -C / \
 && rm /build/nghttp2-${NGHTTP2_VERSION}.tar.gz

COPY artifacts/deps/openldap-${OPENLDAP_VERSION}.tar.gz /build/
RUN tar xzf /build/openldap-${OPENLDAP_VERSION}.tar.gz -C / \
 && rm /build/openldap-${OPENLDAP_VERSION}.tar.gz

COPY artifacts/deps/libssh2-${LIBSSH2_VERSION}.tar.gz /build/
RUN tar xzf /build/libssh2-${LIBSSH2_VERSION}.tar.gz -C / \
 && rm /build/libssh2-${LIBSSH2_VERSION}.tar.gz

COPY artifacts/deps/libunistring-${LIBUNISTRING_VERSION}.tar.gz /build/
RUN tar xzf /build/libunistring-${LIBUNISTRING_VERSION}.tar.gz -C / \
 && rm /build/libunistring-${LIBUNISTRING_VERSION}.tar.gz

COPY artifacts/deps/libidn2-${LIBIDN2_VERSION}.tar.gz /build/
RUN tar xzf /build/libidn2-${LIBIDN2_VERSION}.tar.gz -C / \
 && rm /build/libidn2-${LIBIDN2_VERSION}.tar.gz

COPY artifacts/deps/zstd-${ZSTD_VERSION}.tar.gz /build/
RUN tar xzf /build/zstd-${ZSTD_VERSION}.tar.gz -C / \
 && rm /build/zstd-${ZSTD_VERSION}.tar.gz

COPY artifacts/deps/brotli-${BROTLI_VERSION}.tar.gz /build/
RUN tar xzf /build/brotli-${BROTLI_VERSION}.tar.gz -C / \
 && rm /build/brotli-${BROTLI_VERSION}.tar.gz

COPY artifacts/deps/nghttp3-${NGHTTP3_VERSION}.tar.gz /build/
RUN tar xzf /build/nghttp3-${NGHTTP3_VERSION}.tar.gz -C / \
 && rm /build/nghttp3-${NGHTTP3_VERSION}.tar.gz

COPY artifacts/deps/ngtcp2-${NGTCP2_VERSION}.tar.gz /build/
RUN tar xzf /build/ngtcp2-${NGTCP2_VERSION}.tar.gz -C / \
 && rm /build/ngtcp2-${NGTCP2_VERSION}.tar.gz

RUN ldconfig

WORKDIR /build

COPY artifacts/src/curl-${CURL_VERSION}.tar.gz /build/

RUN tar xzf curl-${CURL_VERSION}.tar.gz \
 && cd curl-${CURL_VERSION} \
 && LDFLAGS="-Wl,-rpath-link,/usr/lib" \
    ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
       --with-openssl \
       --with-zlib \
       --with-nghttp2 \
       --with-gssapi=/usr \
       --with-libssh2 \
       --with-libidn2 \
       --with-zstd \
       --with-brotli \
       --enable-ldap \
       --enable-ldaps \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки curl из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libcurl.a             — статическая библиотека
#   /out/usr/lib/libcurl.so*           — динамическая библиотека
#   /out/usr/include/curl/*.h          — заголовочные файлы
#   /out/usr/lib/pkgconfig/libcurl.pc  — pkg-config
#   /out/usr/bin/curl                  — CLI
# Использование: COPY --from=curl:8.4.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <bison:3.8.2:compilation> ####
#### <openssl:1.1.1w:compilation> ####
#### <kerberos:1.20.1:compilation> ####
#### <nghttp2:1.58.0:compilation> ####
#### <openldap:2.6.6:compilation> ####
#### <libssh2:1.11.0:compilation> ####
#### <libunistring:1.1:compilation> ####
#### <libidn2:2.3.4:compilation> ####
#### <zstd:1.5.5:compilation> ####
#### <brotli:1.1.0:compilation> ####
#### <nghttp3:1.1.0:compilation> ####
#### <ngtcp2:1.2.0:compilation> ####

#### compilation ####
ARG CURL_VERSION=8.4.0

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
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

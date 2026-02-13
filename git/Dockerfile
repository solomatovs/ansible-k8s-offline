# Сборка git из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/bin/git                   — бинарник git
#   /out/usr/libexec/git-core/*        — вспомогательные утилиты
#   /out/usr/share/git-core/*          — шаблоны
# Использование: COPY --from=git:2.42.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <brotli:1.1.0:compilation> ####
#### <zstd:1.5.5:compilation> ####
#### <nghttp2:1.58.0:compilation> ####
#### <nghttp3:1.1.0:compilation> ####
#### <ngtcp2:1.2.0:compilation> ####
#### <libunistring:1.1:compilation> ####
#### <libidn2:2.3.4:compilation> ####
#### <bison:3.8.2:compilation> ####
#### <openssl:1.1.1w:compilation> ####
#### <kerberos:1.20.1:compilation> ####
#### <openldap:2.6.6:compilation> ####
#### <libssh2:1.11.0:compilation> ####
#### <curl:8.4.0:compilation> ####

#### compilation ####
ARG GIT_VERSION=2.42.0

WORKDIR /build

COPY artifacts/src/git-${GIT_VERSION}.tar.gz /build/

RUN tar xzf git-${GIT_VERSION}.tar.gz \
 && cd git-${GIT_VERSION} \
 && make configure \
 && ./configure --prefix=/usr \
       --with-curl=/usr \
       --with-openssl=/usr \
       --with-zlib=/usr \
       --without-tcltk \
 && make -j$(nproc) NO_TCLTK=1 all \
 && make NO_TCLTK=1 DESTDIR=/out install \
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки OpenLDAP из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libldap.a             — статическая библиотека LDAP
#   /out/usr/lib/liblber.a             — статическая библиотека LBER
#   /out/usr/lib/libldap*.so*          — динамические библиотеки
#   /out/usr/include/ldap.h и др.      — заголовочные файлы
# Использование: COPY --from=openldap:2.6.6-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <openssl:1.1.1w:compilation> ####

#### compilation ####
ARG OPENLDAP_VERSION=2.6.6

WORKDIR /build

COPY artifacts/src/openldap-${OPENLDAP_VERSION}.tgz /build/

RUN tar xzf openldap-${OPENLDAP_VERSION}.tgz \
 && cd openldap-${OPENLDAP_VERSION} \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
       --disable-slapd \
       --without-cyrus-sasl \
 && make -C include -j$(nproc) \
 && make -C libraries -j$(nproc) \
 && make -C include DESTDIR=/out install \
 && make -C libraries DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/man 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

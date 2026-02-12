# Сборка статической и динамической библиотеки OpenLDAP из исходников.
# C-зависимость (openssl) подаётся как файловая зависимость из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libldap.a             — статическая библиотека LDAP
#   /out/usr/lib/liblber.a             — статическая библиотека LBER
#   /out/usr/lib/libldap*.so*          — динамические библиотеки
#   /out/usr/include/ldap.h и др.      — заголовочные файлы
# Использование: COPY --from=openldap:2.6.6-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG OPENLDAP_VERSION=2.6.6
ARG OPENSSL_VERSION=1.1.1w

# C-зависимость для сборки (make deps)
COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

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
 && { rm -rf /out/usr/share/man 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки Kerberos 5 (MIT) из исходников.
# MIT Kerberos не поддерживает одновременную сборку static + shared,
# поэтому сборка выполняется в два этапа.
# C-зависимость (openssl) подаётся как файловая зависимость из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libgssapi_krb5.a      — статическая библиотека GSSAPI
#   /out/usr/lib/libkrb5.a             — статическая библиотека Kerberos 5
#   /out/usr/lib/libk5crypto.a         — статическая библиотека k5crypto
#   /out/usr/lib/libkrb5support.a      — статическая библиотека support
#   /out/usr/lib/libcom_err.a          — статическая библиотека com_err
#   /out/usr/lib/lib*.so*              — динамические библиотеки
#   /out/usr/include/krb5/*.h          — заголовочные файлы
#   /out/usr/lib/pkgconfig/krb5*.pc    — pkg-config
# Использование: COPY --from=kerberos:1.20.1-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder-shared

ARG KERBEROS_VERSION=1.20.1
ARG OPENSSL_VERSION=1.1.1w
ARG BISON_VERSION=3.8.2

# --- bison + m4 (build-зависимость) ---
COPY artifacts/deps/bison-${BISON_VERSION}.tar.gz /build/
RUN tar xzf /build/bison-${BISON_VERSION}.tar.gz -C / \
 && rm /build/bison-${BISON_VERSION}.tar.gz

# C-зависимость для сборки (make deps)
COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/krb5-${KERBEROS_VERSION}.tar.gz /build/

# Этап 1: shared-библиотеки
RUN tar xzf krb5-${KERBEROS_VERSION}.tar.gz \
 && cd krb5-${KERBEROS_VERSION}/src \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-shared --disable-static \
       --without-keyutils --without-system-verto \
       --without-tcl \
 && make -j$(nproc) || true \
 && make install DESTDIR=/out \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/man /out/usr/share/doc /out/usr/share/examples 2>/dev/null || true; }

# Этап 2: static-библиотеки
FROM ${TOOLCHAIN_IMAGE} AS builder-static

ARG KERBEROS_VERSION=1.20.1
ARG OPENSSL_VERSION=1.1.1w
ARG BISON_VERSION=3.8.2

# --- bison + m4 (build-зависимость) ---
COPY artifacts/deps/bison-${BISON_VERSION}.tar.gz /build/
RUN tar xzf /build/bison-${BISON_VERSION}.tar.gz -C / \
 && rm /build/bison-${BISON_VERSION}.tar.gz

COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/krb5-${KERBEROS_VERSION}.tar.gz /build/

RUN tar xzf krb5-${KERBEROS_VERSION}.tar.gz \
 && cd krb5-${KERBEROS_VERSION}/src \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --disable-shared --enable-static \
       --without-keyutils --without-system-verto \
       --without-tcl \
 && make -j$(nproc) || true \
 && make install DESTDIR=/out-static \
 && find /out-static -name '*.la' -delete

# Финальный образ — объединяем shared + static + pkg-config
FROM ${BASE_IMAGE}
COPY --from=builder-shared /out /out
COPY --from=builder-static /out-static/usr/lib/*.a /out/usr/lib/

# Сборка статической и динамической библиотеки Kerberos 5 (MIT) из исходников.
# MIT Kerberos не поддерживает одновременную сборку static + shared,
# поэтому сборка выполняется в два этапа в одном контейнере.
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

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <bison:3.8.2:compilation> ####
#### <openssl:1.1.1w:compilation> ####

#### compilation ####
ARG KERBEROS_VERSION=1.20.1

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

# Этап 2: static-библиотеки (перекомпиляция в том же контейнере)
RUN cd /build && rm -rf krb5-${KERBEROS_VERSION} \
 && tar xzf krb5-${KERBEROS_VERSION}.tar.gz \
 && cd krb5-${KERBEROS_VERSION}/src \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --disable-shared --enable-static \
       --without-keyutils --without-system-verto \
       --without-tcl \
 && make -j$(nproc) || true \
 && make install DESTDIR=/out-static \
 && find /out-static -name '*.la' -delete \
 && cp /out-static/usr/lib/*.a /out/usr/lib/ \
 && rm -rf /out-static \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

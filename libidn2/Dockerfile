# Сборка статической и динамической библиотеки libidn2 из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libidn2.a             — статическая библиотека
#   /out/usr/lib/libidn2.so*           — динамическая библиотека
#   /out/usr/include/idn2.h            — заголовочный файл
#   /out/usr/lib/pkgconfig/libidn2.pc  — pkg-config
# Использование: COPY --from=libidn2:2.3.4-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <libunistring:1.1:compilation> ####

#### compilation ####
ARG LIBIDN2_VERSION=2.3.4

WORKDIR /build

COPY artifacts/src/libidn2-${LIBIDN2_VERSION}.tar.gz /build/

RUN tar xzf libidn2-${LIBIDN2_VERSION}.tar.gz \
 && cd libidn2-${LIBIDN2_VERSION} \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/info /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

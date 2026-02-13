# Сборка статической и динамической библиотеки ngtcp2 из исходников.
# Core-библиотека без crypto binding (OpenSSL 1.1.1 не поддерживает QUIC).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libngtcp2.a               — статическая библиотека
#   /out/usr/lib/libngtcp2*.so*            — динамические библиотеки
#   /out/usr/include/ngtcp2/*.h            — заголовочные файлы
#   /out/usr/lib/pkgconfig/libngtcp2.pc    — pkg-config
# Использование: COPY --from=ngtcp2:1.2.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG NGTCP2_VERSION=1.2.0

WORKDIR /build

COPY artifacts/src/ngtcp2-${NGTCP2_VERSION}.tar.gz /build/

RUN tar xzf ngtcp2-${NGTCP2_VERSION}.tar.gz \
 && cd ngtcp2-${NGTCP2_VERSION} \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
       --enable-lib-only \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

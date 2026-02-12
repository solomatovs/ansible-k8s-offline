# Сборка статической и динамической библиотеки liblz4 из исходников.
# Результат: /out (PREFIX=/usr)
#   /out/usr/lib/liblz4.a              — статическая библиотека
#   /out/usr/lib/liblz4.so*            — динамическая библиотека
#   /out/usr/include/lz4.h             — заголовочный файл
#   /out/usr/include/lz4hc.h           — заголовочный файл
#   /out/usr/include/lz4frame.h        — заголовочный файл
#   /out/usr/lib/pkgconfig/liblz4.pc   — pkg-config
# Использование: COPY --from=liblz4:1.9.3-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBLZ4_VERSION=1.9.3


WORKDIR /build

COPY artifacts/src/lz4-${LIBLZ4_VERSION}.tar.gz /build/

RUN mkdir -p /build/lz4 \
 && tar xzf lz4-${LIBLZ4_VERSION}.tar.gz --strip-components=1 -C /build/lz4 \
 && rm lz4-${LIBLZ4_VERSION}.tar.gz

WORKDIR /build/lz4

RUN make -j$(nproc) lib PREFIX=/usr LIBDIR=/usr/lib \
 && make DESTDIR=/out PREFIX=/usr LIBDIR=/usr/lib install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки zlib из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libz.a              — статическая библиотека
#   /out/usr/lib/libz.so*            — динамическая библиотека
#   /out/usr/include/zlib.h          — заголовочные файлы
#   /out/usr/lib/pkgconfig/zlib.pc   — pkg-config
# Использование: COPY --from=zlib:1.3.1-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG ZLIB_VERSION=1.3.1

WORKDIR /build

COPY artifacts/src/zlib-${ZLIB_VERSION}.tar.gz /build/

RUN tar xzf zlib-${ZLIB_VERSION}.tar.gz \
 && cd zlib-${ZLIB_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

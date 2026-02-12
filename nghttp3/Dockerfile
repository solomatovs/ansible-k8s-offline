# Сборка статической и динамической библиотеки nghttp3 из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libnghttp3.a              — статическая библиотека
#   /out/usr/lib/libnghttp3.so*            — динамическая библиотека
#   /out/usr/include/nghttp3/*.h           — заголовочные файлы
#   /out/usr/lib/pkgconfig/libnghttp3.pc   — pkg-config
# Использование: COPY --from=nghttp3:1.1.0-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG NGHTTP3_VERSION=1.1.0

WORKDIR /build

COPY artifacts/src/nghttp3-${NGHTTP3_VERSION}.tar.gz /build/

RUN tar xzf nghttp3-${NGHTTP3_VERSION}.tar.gz \
 && cd nghttp3-${NGHTTP3_VERSION} \
 && ./configure --prefix=/usr --enable-static --enable-shared --enable-lib-only \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

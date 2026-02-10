# Сборка статической и динамической библиотеки nghttp2 из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libnghttp2.a              — статическая библиотека
#   /out/usr/lib/libnghttp2.so*            — динамическая библиотека
#   /out/usr/include/nghttp2/*.h           — заголовочные файлы
#   /out/usr/lib/pkgconfig/libnghttp2.pc   — pkg-config
# Использование: COPY --from=nghttp2:1.58.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG NGHTTP2_VERSION=1.58.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        autoconf \
        automake \
        libtool \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/nghttp2-${NGHTTP2_VERSION}.tar.gz /build/

RUN tar xzf nghttp2-${NGHTTP2_VERSION}.tar.gz \
 && cd nghttp2-${NGHTTP2_VERSION} \
 && ./configure --prefix=/usr --enable-static --enable-shared --enable-lib-only \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

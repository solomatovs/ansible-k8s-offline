# Сборка статической и динамической библиотеки liblzma из исходников xz-utils.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/liblzma.a              — статическая библиотека
#   /out/usr/lib/liblzma.so*            — динамическая библиотека
#   /out/usr/include/lzma.h             — заголовочный файл
#   /out/usr/include/lzma/              — заголовочные файлы
#   /out/usr/lib/pkgconfig/liblzma.pc   — pkg-config
# Использование: COPY --from=liblzma:5.2.2-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LZMA_VERSION=5.2.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/xz-${LZMA_VERSION}.tar.gz /build/

RUN mkdir -p /build/xz \
 && tar xzf xz-${LZMA_VERSION}.tar.gz --strip-components=1 -C /build/xz \
 && rm xz-${LZMA_VERSION}.tar.gz

WORKDIR /build/xz

RUN ./configure --prefix=/usr --libdir=/usr/lib \
      --enable-static --enable-shared \
      --disable-xz --disable-xzdec --disable-lzmadec --disable-lzmainfo \
      --disable-scripts --disable-doc \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

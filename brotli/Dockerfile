# Сборка статической и динамической библиотеки brotli из исходников (cmake).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libbrotlidec.a          — статическая библиотека (decoder)
#   /out/usr/lib/libbrotlienc.a          — статическая библиотека (encoder)
#   /out/usr/lib/libbrotlicommon.a       — статическая библиотека (common)
#   /out/usr/lib/libbrotli*.so*          — динамические библиотеки
#   /out/usr/include/brotli/*.h          — заголовочные файлы
#   /out/usr/lib/pkgconfig/libbrotli*.pc — pkg-config
# Использование: COPY --from=brotli:1.1.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG BROTLI_VERSION=1.1.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/brotli-${BROTLI_VERSION}.tar.gz /build/

RUN tar xzf brotli-${BROTLI_VERSION}.tar.gz \
 && cd brotli-${BROTLI_VERSION} \
 && mkdir build-dir && cd build-dir \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr \
          -DCMAKE_INSTALL_LIBDIR=lib \
          -DBUILD_SHARED_LIBS=ON \
          .. \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Также собираем статические библиотеки
RUN cd brotli-${BROTLI_VERSION} \
 && mkdir build-static && cd build-static \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr \
          -DCMAKE_INSTALL_LIBDIR=lib \
          -DBUILD_SHARED_LIBS=OFF \
          .. \
 && make -j$(nproc) \
 && cp libbrotli*.a /out/usr/lib/

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

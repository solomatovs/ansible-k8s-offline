# Сборка статической и динамической библиотеки libmd из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libmd.a         — статическая библиотека
#   /out/usr/lib/libmd.so*       — динамическая библиотека
#   /out/usr/include/*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/*.pc  — pkg-config
# Использование: COPY --from=libmd:1.1.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LIBMD_VERSION=1.1.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        xz-utils \
        pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/libmd-${LIBMD_VERSION}.tar.xz /build/

RUN tar -xf libmd-${LIBMD_VERSION}.tar.xz \
 && cd libmd-${LIBMD_VERSION} \
 && ./configure --prefix=/usr --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

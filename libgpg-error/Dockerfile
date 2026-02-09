# Сборка статической библиотеки libgpg-error из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libgpg-error.a        — статическая библиотека
#   /out/usr/include/gpg-error.h       — заголовочный файл
#   /out/usr/lib/pkgconfig/gpg-error.pc — pkg-config (если сгенерирован)
#   /out/usr/bin/gpg-error-config      — config-скрипт
# Использование: COPY --from=libgpg-error-astra:1.35-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GPG_ERROR_VERSION=1.35

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/libgpg-error-${GPG_ERROR_VERSION}.tar.bz2 /build/

RUN mkdir -p /build/libgpg-error \
 && tar xjf libgpg-error-${GPG_ERROR_VERSION}.tar.bz2 --strip-components=1 -C /build/libgpg-error \
 && rm libgpg-error-${GPG_ERROR_VERSION}.tar.bz2

WORKDIR /build/libgpg-error

RUN ./configure --prefix=/usr --libdir=/usr/lib --enable-static --disable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && find /out -name '*.so*' -delete \
 && { rm -rf /out/usr/share/locale /out/usr/share/info /out/usr/share/man 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической библиотеки libgcrypt из исходников.
# C-зависимость (libgpg-error) подаётся как файловая зависимость из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libgcrypt.a           — статическая библиотека
#   /out/usr/include/gcrypt.h          — заголовочный файл
#   /out/usr/bin/libgcrypt-config      — config-скрипт
# Использование: COPY --from=libgcrypt-astra:1.7.6-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GCRYPT_VERSION=1.7.6
ARG GPG_ERROR_VERSION=1.35

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

# C-зависимость для сборки (make deps)
COPY artifacts/deps/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz /build/
RUN tar xzf /build/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz -C / \
 && rm /build/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/libgcrypt-${GCRYPT_VERSION}.tar.bz2 /build/

RUN mkdir -p /build/libgcrypt \
 && tar xjf libgcrypt-${GCRYPT_VERSION}.tar.bz2 --strip-components=1 -C /build/libgcrypt \
 && rm libgcrypt-${GCRYPT_VERSION}.tar.bz2

WORKDIR /build/libgcrypt

RUN ./configure --prefix=/usr --libdir=/usr/lib --enable-static --disable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && find /out -name '*.so*' -delete \
 && { rm -rf /out/usr/share/info /out/usr/share/man 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

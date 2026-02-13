# Сборка статической и динамической библиотеки libgcrypt из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libgcrypt.a           — статическая библиотека
#   /out/usr/lib/libgcrypt.so*         — динамическая библиотека
#   /out/usr/include/gcrypt.h          — заголовочный файл
#   /out/usr/bin/libgcrypt-config      — config-скрипт
# Использование: COPY --from=libgcrypt:1.7.6-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <libgpg-error:1.35:compilation> ####

#### compilation ####
ARG LIBGCRYPT_VERSION=1.7.6

WORKDIR /build

COPY artifacts/src/libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2 /build/

RUN mkdir -p /build/libgcrypt \
 && tar xjf libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2 --strip-components=1 -C /build/libgcrypt \
 && rm libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2

WORKDIR /build/libgcrypt

RUN ./configure --prefix=/usr --libdir=/usr/lib --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/info /out/usr/share/man 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

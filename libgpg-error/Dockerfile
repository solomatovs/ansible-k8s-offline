# Сборка статической и динамической библиотеки libgpg-error из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libgpg-error.a        — статическая библиотека
#   /out/usr/lib/libgpg-error.so*      — динамическая библиотека
#   /out/usr/include/gpg-error.h       — заголовочный файл
#   /out/usr/lib/pkgconfig/gpg-error.pc — pkg-config (если сгенерирован)
#   /out/usr/bin/gpg-error-config      — config-скрипт
# Использование: COPY --from=libgpg-error:1.35-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBGPG_ERROR_VERSION=1.35


WORKDIR /build

COPY artifacts/src/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2 /build/

RUN mkdir -p /build/libgpg-error \
 && tar xjf libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2 --strip-components=1 -C /build/libgpg-error \
 && rm libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2

WORKDIR /build/libgpg-error

RUN ./configure --prefix=/usr --libdir=/usr/lib --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/locale /out/usr/share/info /out/usr/share/man 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

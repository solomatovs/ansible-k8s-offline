# Сборка статических библиотек libmount, libblkid и libuuid из util-linux.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libmount.a              — статическая библиотека
#   /out/usr/lib/libblkid.a              — статическая библиотека
#   /out/usr/lib/libuuid.a               — статическая библиотека
#   /out/usr/include/libmount/libmount.h — заголовочный файл
#   /out/usr/include/blkid/blkid.h       — заголовочный файл
#   /out/usr/include/uuid/uuid.h         — заголовочный файл
#   /out/usr/lib/pkgconfig/mount.pc      — pkg-config
#   /out/usr/lib/pkgconfig/blkid.pc      — pkg-config
#   /out/usr/lib/pkgconfig/uuid.pc       — pkg-config
# Использование: COPY --from=libmount-astra:2.30.2-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG UTIL_LINUX_VERSION=2.30.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        autoconf \
        automake \
        autopoint \
        libtool \
        gettext \
        pkg-config \
        bison \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/util-linux-${UTIL_LINUX_VERSION}.tar.gz /build/

RUN mkdir -p /build/util-linux \
 && tar xzf util-linux-${UTIL_LINUX_VERSION}.tar.gz --strip-components=1 -C /build/util-linux \
 && rm util-linux-${UTIL_LINUX_VERSION}.tar.gz

WORKDIR /build/util-linux

# GitHub-архив не содержит .tarball-version — создаём вручную,
# иначе autogen.sh сгенерирует Version: UNKNOWN в .pc файлах.
RUN echo "${UTIL_LINUX_VERSION}" > .tarball-version \
 && ./autogen.sh \
 && ./configure \
      --prefix=/usr \
      --libdir=/usr/lib \
      --enable-static \
      --disable-shared \
      --disable-all-programs \
      --enable-libblkid \
      --enable-libmount \
      --enable-libuuid \
      --without-python \
      --without-ncurses \
      --without-tinfo \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && find /out -name '*.so*' -delete \
 && { rm -rf /out/usr/share /out/usr/sbin /out/usr/bin 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

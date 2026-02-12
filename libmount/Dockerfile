# Сборка статических и динамических библиотек libmount, libblkid и libuuid из util-linux.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libmount.{a,so*}          — статическая и динамическая библиотека
#   /out/usr/lib/libblkid.{a,so*}          — статическая и динамическая библиотека
#   /out/usr/lib/libuuid.{a,so*}           — статическая и динамическая библиотека
#   /out/usr/include/libmount/libmount.h   — заголовочный файл
#   /out/usr/include/blkid/blkid.h         — заголовочный файл
#   /out/usr/include/uuid/uuid.h           — заголовочный файл
#   /out/usr/lib/pkgconfig/mount.pc        — pkg-config
#   /out/usr/lib/pkgconfig/blkid.pc        — pkg-config
#   /out/usr/lib/pkgconfig/uuid.pc         — pkg-config
# Использование: COPY --from=libmount:2.30.2-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBMOUNT_VERSION=2.30.2
ARG BISON_VERSION=3.8.2

# --- bison + m4 (build-зависимость) ---
COPY artifacts/deps/bison-${BISON_VERSION}.tar.gz /build/
RUN tar xzf /build/bison-${BISON_VERSION}.tar.gz -C / \
 && rm /build/bison-${BISON_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/util-linux-${LIBMOUNT_VERSION}.tar.gz /build/

RUN mkdir -p /build/util-linux \
 && tar xzf util-linux-${LIBMOUNT_VERSION}.tar.gz --strip-components=1 -C /build/util-linux \
 && rm util-linux-${LIBMOUNT_VERSION}.tar.gz

WORKDIR /build/util-linux

# GitHub-архив не содержит .tarball-version — создаём вручную,
# иначе autogen.sh сгенерирует Version: UNKNOWN в .pc файлах.
RUN echo "${LIBMOUNT_VERSION}" > .tarball-version \
 && ./autogen.sh \
 && ./configure \
      --prefix=/usr \
      --libdir=/usr/lib \
      --enable-static \
      --enable-shared \
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
 && { rm -rf /out/usr/share /out/usr/sbin /out/usr/bin 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки libdevmapper из LVM2.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libdevmapper.a       — статическая библиотека
#   /out/usr/lib/libdevmapper.so*     — динамическая библиотека
#   /out/usr/include/libdevmapper.h   — заголовочный файл
#   /out/usr/lib/pkgconfig/devmapper.pc — pkg-config
# Использование: COPY --from=libdevmapper:2.03.25-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBDEVMAPPER_VERSION=2.03.25
ARG LIBAIO_VERSION=0.3.113

# --- libaio (build-зависимость) ---
COPY artifacts/deps/libaio-${LIBAIO_VERSION}.tar.gz /build/
RUN tar xzf /build/libaio-${LIBAIO_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/libaio-${LIBAIO_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/lvm2-${LIBDEVMAPPER_VERSION}.tar.gz /build/

RUN mkdir -p /build/lvm2 \
 && tar xzf lvm2-${LIBDEVMAPPER_VERSION}.tar.gz --strip-components=1 -C /build/lvm2 \
 && rm lvm2-${LIBDEVMAPPER_VERSION}.tar.gz

WORKDIR /build/lvm2

RUN ./configure \
      --prefix=/usr \
      --libdir=/usr/lib \
      --enable-static_link \
      --disable-selinux \
      --disable-udev_sync \
      --disable-udev_rules \
 && make -j$(nproc) -C libdm

RUN make -C libdm DESTDIR=/out install_static install_dynamic install_include install_pkgconfig

# Fat package: включаем libaio в /out.
RUN cp -a /usr/lib/libaio.a /usr/lib/libaio.so* /out/usr/lib/ 2>/dev/null || true \
 && cp -p /usr/include/libaio.h /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/lib/pkgconfig/libaio.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

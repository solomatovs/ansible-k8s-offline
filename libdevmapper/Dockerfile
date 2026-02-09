# Сборка статической библиотеки libdevmapper из LVM2.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libdevmapper.a       — статическая библиотека
#   /out/usr/include/libdevmapper.h   — заголовочный файл
#   /out/usr/lib/pkgconfig/devmapper.pc — pkg-config
# Использование: COPY --from=libdevmapper-astra:2.03.25-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LVM2_VERSION=2.03.25

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        libaio-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/lvm2-${LVM2_VERSION}.tar.gz /build/

RUN mkdir -p /build/lvm2 \
 && tar xzf lvm2-${LVM2_VERSION}.tar.gz --strip-components=1 -C /build/lvm2 \
 && rm lvm2-${LVM2_VERSION}.tar.gz

WORKDIR /build/lvm2

RUN ./configure \
      --prefix=/usr \
      --libdir=/usr/lib \
      --enable-static_link \
      --disable-selinux \
      --disable-udev_sync \
      --disable-udev_rules \
 && make -j$(nproc) -C libdm

RUN make -C libdm DESTDIR=/out install_static install_include install_pkgconfig

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

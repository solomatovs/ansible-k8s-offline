# Сборка статической и динамической библиотеки libdevmapper из LVM2.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libdevmapper.a       — статическая библиотека
#   /out/usr/lib/libdevmapper.so*     — динамическая библиотека
#   /out/usr/include/libdevmapper.h   — заголовочный файл
#   /out/usr/lib/pkgconfig/devmapper.pc — pkg-config
# Использование: COPY --from=libdevmapper:2.03.25-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <libaio:0.3.113:compilation> ####

#### compilation ####
ARG LIBDEVMAPPER_VERSION=2.03.25

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

RUN make -C libdm DESTDIR=/out install_static install_dynamic install_include install_pkgconfig \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

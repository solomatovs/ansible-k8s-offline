# Сборка статических и динамических библиотек libbtrfs и libbtrfsutil из btrfs-progs.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libbtrfs.{a,so*}          — статическая и динамическая библиотека
#   /out/usr/lib/libbtrfsutil.{a,so*}      — статическая и динамическая библиотека
#   /out/usr/include/btrfs/*.h             — заголовочные файлы btrfs
#   /out/usr/include/btrfsutil.h           — заголовочный файл btrfsutil
#   /out/usr/lib/pkgconfig/libbtrfsutil.pc — pkg-config
# Использование: COPY --from=libbtrfs:6.6.3-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <zstd:1.5.5:compilation> ####
#### <lzo:2.10:compilation> ####
#### <e2fsprogs:1.47.0:compilation> ####
#### <bison:3.8.2:compilation> ####
#### <libcap:2.25:compilation> ####
#### <libmount:2.30.2:compilation> ####
#### <libudev:241:compilation> ####

#### compilation ####
ARG LIBBTRFS_VERSION=6.6.3

WORKDIR /build

COPY artifacts/src/btrfs-progs-${LIBBTRFS_VERSION}.tar.gz /build/

RUN mkdir -p /build/btrfs-progs \
 && tar xzf btrfs-progs-${LIBBTRFS_VERSION}.tar.gz --strip-components=1 -C /build/btrfs-progs \
 && rm btrfs-progs-${LIBBTRFS_VERSION}.tar.gz

WORKDIR /build/btrfs-progs

RUN ./autogen.sh \
 && ./configure \
      --prefix=/usr \
      --disable-documentation \
      --disable-programs \
      --disable-python \
 && make -j$(nproc)

RUN mkdir -p /out/usr/lib /out/usr/include/btrfs /out/usr/lib/pkgconfig \
 && cp libbtrfs.a /out/usr/lib/ \
 && cp libbtrfsutil.a /out/usr/lib/ \
 && cp -a libbtrfs.so* /out/usr/lib/ 2>/dev/null || true \
 && cp -a libbtrfsutil/libbtrfsutil.so* /out/usr/lib/ 2>/dev/null || true \
 && cp libbtrfs/*.h /out/usr/include/btrfs/ \
 && cp kernel-lib/list.h kernel-lib/rbtree.h kernel-lib/rbtree_types.h /out/usr/include/btrfs/ \
 && cp libbtrfsutil/btrfsutil.h /out/usr/include/ \
 && cp libbtrfsutil/libbtrfsutil.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

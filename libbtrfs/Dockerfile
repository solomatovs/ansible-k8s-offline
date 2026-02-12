# Сборка статических и динамических библиотек libbtrfs и libbtrfsutil из btrfs-progs.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libbtrfs.{a,so*}          — статическая и динамическая библиотека
#   /out/usr/lib/libbtrfsutil.{a,so*}      — статическая и динамическая библиотека
#   /out/usr/include/btrfs/*.h             — заголовочные файлы btrfs
#   /out/usr/include/btrfsutil.h           — заголовочный файл btrfsutil
#   /out/usr/lib/pkgconfig/libbtrfsutil.pc — pkg-config
# Использование: COPY --from=libbtrfs:6.6.3-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBBTRFS_VERSION=6.6.3
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.5
ARG LIBMOUNT_VERSION=2.30.2
ARG LZO_VERSION=2.10
ARG E2FSPROGS_VERSION=1.47.0
ARG LIBUDEV_VERSION=241

# C-зависимости из наших сборок (вместо apt -dev пакетов)
COPY artifacts/deps/lzo-${LZO_VERSION}.tar.gz /build/
RUN tar xzf /build/lzo-${LZO_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/lzo-${LZO_VERSION}.tar.gz

COPY artifacts/deps/e2fsprogs-${E2FSPROGS_VERSION}.tar.gz /build/
RUN tar xzf /build/e2fsprogs-${E2FSPROGS_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/e2fsprogs-${E2FSPROGS_VERSION}.tar.gz

COPY artifacts/deps/libudev-${LIBUDEV_VERSION}.tar.gz /build/
RUN tar xzf /build/libudev-${LIBUDEV_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/libudev-${LIBUDEV_VERSION}.tar.gz

COPY artifacts/deps/zlib-${ZLIB_VERSION}.tar.gz /build/
RUN tar xzf /build/zlib-${ZLIB_VERSION}.tar.gz -C / \
 && rm /build/zlib-${ZLIB_VERSION}.tar.gz

COPY artifacts/deps/zstd-${ZSTD_VERSION}.tar.gz /build/
RUN tar xzf /build/zstd-${ZSTD_VERSION}.tar.gz -C / \
 && rm /build/zstd-${ZSTD_VERSION}.tar.gz

COPY artifacts/deps/libmount-${LIBMOUNT_VERSION}.tar.gz /build/
RUN tar xzf /build/libmount-${LIBMOUNT_VERSION}.tar.gz -C / \
 && rm /build/libmount-${LIBMOUNT_VERSION}.tar.gz

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
 && cp libbtrfsutil/libbtrfsutil.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true

# Fat package: включаем все build-зависимости (.a, .so, headers, pkgconfig) в /out.
RUN for lib in libz libzstd libmount libblkid libuuid liblzo2 \
              libcom_err libe2p libext2fs libss libudev; do \
      cp -a /usr/lib/${lib}.a /out/usr/lib/ 2>/dev/null || true; \
      cp -a /usr/lib/${lib}.so* /out/usr/lib/ 2>/dev/null || true; \
    done \
 && cp -p /usr/include/zlib.h /usr/include/zconf.h /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/zstd.h /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/libmount /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/blkid /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/uuid /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/lzo/*.h /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/ext2fs /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/libudev.h /out/usr/include/ 2>/dev/null || true \
 && for pc in zlib libzstd mount blkid uuid lzo2 com_err e2p ext2fs ss libudev; do \
      cp -p /usr/lib/pkgconfig/${pc}.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true; \
    done

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

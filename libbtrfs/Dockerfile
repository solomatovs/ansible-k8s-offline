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

ARG BTRFS_VERSION=6.6.3
ARG ZLIB_VERSION=1.3.1
ARG ZSTD_VERSION=1.5.5
ARG LIBMOUNT_VERSION=2.30.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        autoconf \
        automake \
        liblzo2-dev \
        e2fslibs-dev \
        libudev-dev \
        python3 \
        python3-setuptools \
 && rm -rf /var/lib/apt/lists/*

# C-зависимости из наших сборок (вместо apt -dev пакетов)
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

COPY artifacts/src/btrfs-progs-${BTRFS_VERSION}.tar.gz /build/

RUN mkdir -p /build/btrfs-progs \
 && tar xzf btrfs-progs-${BTRFS_VERSION}.tar.gz --strip-components=1 -C /build/btrfs-progs \
 && rm btrfs-progs-${BTRFS_VERSION}.tar.gz

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

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статических библиотек libbtrfs и libbtrfsutil из btrfs-progs.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libbtrfs.a           — статическая библиотека
#   /out/usr/lib/libbtrfsutil.a       — статическая библиотека
#   /out/usr/include/btrfs/*.h        — заголовочные файлы btrfs
#   /out/usr/include/btrfsutil.h      — заголовочный файл btrfsutil
#   /out/usr/lib/pkgconfig/libbtrfsutil.pc — pkg-config
# Использование: COPY --from=libbtrfs-astra:6.6.3-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG BTRFS_VERSION=6.6.3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        autoconf \
        automake \
        uuid-dev \
        libblkid-dev \
        zlib1g-dev \
        liblzo2-dev \
        libzstd-dev \
        e2fslibs-dev \
        libudev-dev \
        python3 \
        python3-setuptools \
 && rm -rf /var/lib/apt/lists/*

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
 && make -j$(nproc) libbtrfs.a libbtrfsutil.a

RUN mkdir -p /out/usr/lib /out/usr/include/btrfs /out/usr/lib/pkgconfig \
 && cp libbtrfs.a /out/usr/lib/ \
 && cp libbtrfsutil.a /out/usr/lib/ \
 && cp libbtrfs/*.h /out/usr/include/btrfs/ \
 && cp libbtrfsutil/btrfsutil.h /out/usr/include/ \
 && cp libbtrfsutil/libbtrfsutil.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

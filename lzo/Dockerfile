# Сборка LZO (Lempel-Ziv-Oberhumer) из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/lzo/lzo1x.h
#   /out/usr/lib/x86_64-linux-gnu/liblzo2.{a,so*}
#   /out/usr/lib/x86_64-linux-gnu/pkgconfig/lzo2.pc
# Используется как build-зависимость: libbtrfs (btrfs-progs).

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LZO_VERSION=2.10


WORKDIR /build

COPY artifacts/src/lzo-${LZO_VERSION}.tar.gz /build/

RUN tar xzf lzo-${LZO_VERSION}.tar.gz \
 && rm lzo-${LZO_VERSION}.tar.gz

RUN cd lzo-${LZO_VERSION} \
 && ./configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --enable-shared \
      --enable-static \
 && make -j$(nproc) \
 && make check \
 && make DESTDIR=/out install

# Удаляем документацию
RUN rm -rf /out/usr/share \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

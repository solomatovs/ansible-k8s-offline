# Сборка статической и динамической библиотеки zstd из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libzstd.a             — статическая библиотека
#   /out/usr/lib/libzstd.so*           — динамическая библиотека
#   /out/usr/include/zstd.h и др.      — заголовочные файлы
#   /out/usr/lib/pkgconfig/libzstd.pc  — pkg-config
# Использование: COPY --from=zstd:1.5.5-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG ZSTD_VERSION=1.5.5


WORKDIR /build

COPY artifacts/src/zstd-${ZSTD_VERSION}.tar.gz /build/

RUN tar xzf zstd-${ZSTD_VERSION}.tar.gz \
 && cd zstd-${ZSTD_VERSION} \
 && make -j$(nproc) PREFIX=/usr lib \
 && make PREFIX=/usr DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

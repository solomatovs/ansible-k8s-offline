# Сборка статической и динамической библиотеки liblzma из исходников xz-utils.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/liblzma.a              — статическая библиотека
#   /out/usr/lib/liblzma.so*            — динамическая библиотека
#   /out/usr/include/lzma.h             — заголовочный файл
#   /out/usr/include/lzma/              — заголовочные файлы
#   /out/usr/lib/pkgconfig/liblzma.pc   — pkg-config
# Использование: COPY --from=liblzma:5.2.2-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG LIBLZMA_VERSION=5.2.2


WORKDIR /build

COPY artifacts/src/xz-${LIBLZMA_VERSION}.tar.gz /build/

RUN mkdir -p /build/xz \
 && tar xzf xz-${LIBLZMA_VERSION}.tar.gz --strip-components=1 -C /build/xz \
 && rm xz-${LIBLZMA_VERSION}.tar.gz

WORKDIR /build/xz

RUN ./configure --prefix=/usr --libdir=/usr/lib \
      --enable-static --enable-shared \
      --disable-xz --disable-xzdec --disable-lzmadec --disable-lzmainfo \
      --disable-scripts --disable-doc \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

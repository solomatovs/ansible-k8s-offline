# Сборка статической и динамической библиотеки libseccomp из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libseccomp.a         — статическая библиотека
#   /out/usr/lib/libseccomp.so*       — динамическая библиотека
#   /out/usr/include/seccomp.h        — заголовочный файл
#   /out/usr/lib/pkgconfig/libseccomp.pc — pkg-config
# Использование: COPY --from=libseccomp:2.5.5-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG SECCOMP_VERSION=2.5.5

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        gperf \
        pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/libseccomp-${SECCOMP_VERSION}.tar.gz /build/

RUN mkdir -p /build/libseccomp \
 && tar xzf libseccomp-${SECCOMP_VERSION}.tar.gz --strip-components=1 -C /build/libseccomp \
 && rm libseccomp-${SECCOMP_VERSION}.tar.gz

WORKDIR /build/libseccomp

RUN ./configure --prefix=/usr --libdir=/usr/lib --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

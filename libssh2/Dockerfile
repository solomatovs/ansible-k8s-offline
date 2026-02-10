# Сборка статической и динамической библиотеки libssh2 из исходников.
# C-зависимости (openssl, zlib) подаются как файловые зависимости из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libssh2.a              — статическая библиотека
#   /out/usr/lib/libssh2.so*            — динамическая библиотека
#   /out/usr/include/libssh2*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/libssh2.pc   — pkg-config
# Использование: COPY --from=libssh2:1.11.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LIBSSH2_VERSION=1.11.0
ARG OPENSSL_VERSION=1.1.1w
ARG ZLIB_VERSION=1.3.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        autoconf \
        automake \
        libtool \
 && rm -rf /var/lib/apt/lists/*

# C-зависимости для сборки (make deps)
COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

COPY artifacts/deps/zlib-${ZLIB_VERSION}.tar.gz /build/
RUN tar xzf /build/zlib-${ZLIB_VERSION}.tar.gz -C / \
 && rm /build/zlib-${ZLIB_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/libssh2-${LIBSSH2_VERSION}.tar.gz /build/

RUN tar xzf libssh2-${LIBSSH2_VERSION}.tar.gz \
 && cd libssh2-${LIBSSH2_VERSION} \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
       --with-libssl-prefix=/usr \
       --with-libz \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

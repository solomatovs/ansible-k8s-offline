# Сборка статической и динамической библиотеки OpenSSL из исходников.
# C-зависимость (zlib) подаётся как файловая зависимость из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libssl.a               — статическая библиотека SSL
#   /out/usr/lib/libcrypto.a            — статическая библиотека Crypto
#   /out/usr/lib/libssl.so*             — динамическая библиотека SSL
#   /out/usr/lib/libcrypto.so*          — динамическая библиотека Crypto
#   /out/usr/include/openssl/*.h        — заголовочные файлы
#   /out/usr/lib/pkgconfig/openssl.pc   — pkg-config
# Использование: COPY --from=openssl:1.1.1w-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG OPENSSL_VERSION=1.1.1w
ARG ZLIB_VERSION=1.3.1

# C-зависимость для сборки (make deps)
COPY artifacts/deps/zlib-${ZLIB_VERSION}.tar.gz /build/
RUN tar xzf /build/zlib-${ZLIB_VERSION}.tar.gz -C / \
 && rm /build/zlib-${ZLIB_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/openssl-${OPENSSL_VERSION}.tar.gz /build/

RUN tar xzf openssl-${OPENSSL_VERSION}.tar.gz \
 && cd openssl-${OPENSSL_VERSION} \
 && ./config --prefix=/usr --libdir=/usr/lib \
       shared zlib \
       -Wl,-rpath=/usr/lib \
 && make -j$(nproc) \
 && make install_sw DESTDIR=/out \
 && find /out -name '*.la' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки OpenSSL из исходников.
# Зависимости подключаются через шаблонные ссылки (#### <project:profile:region> ####).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libssl.a               — статическая библиотека SSL
#   /out/usr/lib/libcrypto.a            — статическая библиотека Crypto
#   /out/usr/lib/libssl.so*             — динамическая библиотека SSL
#   /out/usr/lib/libcrypto.so*          — динамическая библиотека Crypto
#   /out/usr/include/openssl/*.h        — заголовочные файлы
#   /out/usr/lib/pkgconfig/openssl.pc   — pkg-config
# Использование: COPY --from=openssl:1.1.1w-r1-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####

#### compilation ####
ARG OPENSSL_VERSION=1.1.1w
WORKDIR /build
COPY artifacts/src/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf openssl-${OPENSSL_VERSION}.tar.gz \
 && cd openssl-${OPENSSL_VERSION} \
 && ./config --prefix=/usr --libdir=/usr/lib \
       shared zlib \
       -Wl,-rpath=/usr/lib \
 && make -j$(nproc) \
 && make install_sw DESTDIR=/out \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка статической и динамической библиотеки libssh2 из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libssh2.a              — статическая библиотека
#   /out/usr/lib/libssh2.so*            — динамическая библиотека
#   /out/usr/include/libssh2*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/libssh2.pc   — pkg-config
# Использование: COPY --from=libssh2:1.11.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <zlib:1.3.1:compilation> ####
#### <openssl:1.1.1w:compilation> ####

#### compilation ####
ARG LIBSSH2_VERSION=1.11.0

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
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

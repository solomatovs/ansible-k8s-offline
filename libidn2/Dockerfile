# Сборка статической и динамической библиотеки libidn2 из исходников.
# C-зависимость (libunistring) подаётся как файловая зависимость из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libidn2.a             — статическая библиотека
#   /out/usr/lib/libidn2.so*           — динамическая библиотека
#   /out/usr/include/idn2.h            — заголовочный файл
#   /out/usr/lib/pkgconfig/libidn2.pc  — pkg-config
# Использование: COPY --from=libidn2:2.3.4-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBIDN2_VERSION=2.3.4
ARG LIBUNISTRING_VERSION=1.1

# C-зависимость для сборки (make deps)
COPY artifacts/deps/libunistring-${LIBUNISTRING_VERSION}.tar.gz /build/
RUN tar xzf /build/libunistring-${LIBUNISTRING_VERSION}.tar.gz -C / \
 && rm /build/libunistring-${LIBUNISTRING_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/libidn2-${LIBIDN2_VERSION}.tar.gz /build/

RUN tar xzf libidn2-${LIBIDN2_VERSION}.tar.gz \
 && cd libidn2-${LIBIDN2_VERSION} \
 && ./configure --prefix=/usr --libdir=/usr/lib \
       --enable-static --enable-shared \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/info /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

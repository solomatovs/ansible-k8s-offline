# Сборка статической и динамической библиотеки libunistring из исходников.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libunistring.a      — статическая библиотека
#   /out/usr/lib/libunistring.so*    — динамическая библиотека
#   /out/usr/include/unistr.h и др.  — заголовочные файлы
# Использование: COPY --from=libunistring:1.1-build /out /

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBUNISTRING_VERSION=1.1


WORKDIR /build

COPY artifacts/src/libunistring-${LIBUNISTRING_VERSION}.tar.gz /build/

RUN tar xzf libunistring-${LIBUNISTRING_VERSION}.tar.gz \
 && cd libunistring-${LIBUNISTRING_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && find /out -name '*.la' -delete \
 && { rm -rf /out/usr/share/info /out/usr/share/doc 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

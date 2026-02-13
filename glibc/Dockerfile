# Сборка glibc из исходников (runtime + dev).
# Результат: /out — runtime .so + dev-файлы (headers, .a, .o — замена libc6-dev).
#   /out/lib/x86_64-linux-gnu/libc-2.28.so          — основная библиотека
#   /out/lib/x86_64-linux-gnu/ld-2.28.so            — динамический линкер
#   /out/usr/lib/x86_64-linux-gnu/libc.a             — статическая библиотека
#   /out/usr/lib/x86_64-linux-gnu/crt1.o             — CRT startup
#   /out/usr/include/stdio.h, stdlib.h ...           — C headers
# Использование: COPY --from=glibc:2.28-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG BISON_IMAGE
ARG GAWK_IMAGE

FROM ${BISON_IMAGE} AS bison-build
FROM ${GAWK_IMAGE} AS gawk-build

FROM ${BASE_IMAGE} AS builder

ARG GLIBC_VERSION=2.28
ARG KERNEL_VERSION=4.15.18

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        python3 \
 && rm -rf /var/lib/apt/lists/*

# --- bison + m4 (парсер-генератор, нужен glibc build system) ---
COPY --from=bison-build /out/ /

# --- gawk (GNU awk, нужен glibc build system) ---
COPY --from=gawk-build /out/ /

# --- Kernel headers (UAPI) из исходников ядра ---
# Вместо linux-headers-* из apt: скачиваем исходники ядра и делаем
# make headers_install — стандартный способ получить sanitized UAPI headers.
# Результат: /usr/include/{linux,asm,asm-generic}/ — всё что нужно glibc.
COPY artifacts/src/linux-${KERNEL_VERSION}.tar.xz /build/
RUN tar xJf /build/linux-${KERNEL_VERSION}.tar.xz -C /build \
 && make -C /build/linux-${KERNEL_VERSION} headers_install INSTALL_HDR_PATH=/usr \
 && rm -rf /build/linux-${KERNEL_VERSION} /build/linux-${KERNEL_VERSION}.tar.xz

WORKDIR /build

COPY artifacts/src/glibc-${GLIBC_VERSION}.tar.xz /build/

RUN tar xJf glibc-${GLIBC_VERSION}.tar.xz \
 && rm glibc-${GLIBC_VERSION}.tar.xz

# glibc ОБЯЗАТЕЛЬНО собирается в отдельной директории (не в source tree)
RUN mkdir build && cd build \
 && ../glibc-${GLIBC_VERSION}/configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --with-headers=/usr/include \
      --enable-kernel=3.2 \
      --enable-multi-arch \
      --enable-stack-protector=strong \
      libc_cv_slibdir=/lib/x86_64-linux-gnu \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Оставляем runtime .so + dev-файлы (headers, .a, .o — замена libc6-dev).
# Удаляем документацию, locale, утилиты (кроме sln в /out/sbin/).
RUN rm -rf /out/usr/share /out/usr/bin /out/usr/sbin \
           /out/usr/libexec /out/var /out/etc

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

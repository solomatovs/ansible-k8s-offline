# Сборка runtime-библиотек glibc из исходников.
# Результат: /out — только .so файлы (runtime), без headers/static/locale.
#   /out/lib/x86_64-linux-gnu/libc-2.28.so    — основная библиотека
#   /out/lib/x86_64-linux-gnu/ld-2.28.so      — динамический линкер
#   /out/lib/x86_64-linux-gnu/libm-2.28.so    — math library
#   и другие runtime .so
# Использование: tar xzf glibc-2.28.tar.gz -C / && ldconfig
#
# Зависимости (должны быть извлечены до сборки: make deps):
#   - artifacts/deps/bison-<version>.tar.gz
#   - artifacts/deps/gawk-<version>.tar.gz

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GLIBC_VERSION=2.28
ARG KERNEL_VERSION=4.15.18
ARG BISON_VERSION=3.8.2
ARG GAWK_VERSION=5.2.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        python3 \
 && rm -rf /var/lib/apt/lists/*

# --- bison + m4 (парсер-генератор, нужен glibc build system) ---
COPY artifacts/deps/bison-${BISON_VERSION}.tar.gz /build/
RUN tar xzf /build/bison-${BISON_VERSION}.tar.gz -C / \
 && rm /build/bison-${BISON_VERSION}.tar.gz

# --- gawk (GNU awk, нужен glibc build system) ---
COPY artifacts/deps/gawk-${GAWK_VERSION}.tar.gz /build/
RUN tar xzf /build/gawk-${GAWK_VERSION}.tar.gz -C / \
 && rm /build/gawk-${GAWK_VERSION}.tar.gz

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

# Оставляем только runtime .so (без headers, static libs, locale, утилит)
RUN find /out -name '*.a' -delete \
 && find /out -name '*.o' -delete \
 && rm -rf /out/usr/include /out/usr/share /out/usr/bin /out/usr/sbin \
           /out/usr/libexec /out/var /out/etc

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

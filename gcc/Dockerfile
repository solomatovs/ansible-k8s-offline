# Сборка GCC (GNU Compiler Collection) из исходников.
# Два режима:
#   1) Bootstrap (TOOLCHAIN_GCC_IMAGE не задан): FROM BASE_IMAGE + apt build-essential
#      Используется для первой версии gcc (8.5.0), собираемой системным компилятором.
#   2) Toolchain (TOOLCHAIN_GCC_IMAGE задан): FROM TOOLCHAIN_GCC_IMAGE
#      Используется для новых версий gcc, собираемых нашим компилятором.
#
# Результат: /out — полный компилятор GCC (gcc, g++, runtime-библиотеки).
#   /out/usr/bin/gcc                          — компилятор C
#   /out/usr/bin/g++                          — компилятор C++
#   /out/usr/lib/x86_64-linux-gnu/libgcc_s.so — runtime-библиотека
#   /out/usr/lib/x86_64-linux-gnu/libstdc++.so — C++ runtime
# Использование: tar xzf gcc-<version>.tar.gz -C / && ldconfig

ARG TOOLCHAIN_GCC_IMAGE=
ARG BASE_IMAGE=astra-linux:2.12

# --- Bootstrap stage: используется когда TOOLCHAIN_GCC_IMAGE не задан ---
FROM ${BASE_IMAGE} AS base-bootstrap

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        flex \
        texinfo \
        file \
        zlib1g-dev \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
 && rm -rf /var/lib/apt/lists/*

# --- Выбор builder: toolchain если задан, иначе bootstrap ---
FROM ${TOOLCHAIN_GCC_IMAGE:-base-bootstrap} AS builder

#### compilation ####
ARG GCC_VERSION=8.5.0

WORKDIR /build

COPY artifacts/src/gcc-${GCC_VERSION}.tar.xz /build/

RUN tar xJf gcc-${GCC_VERSION}.tar.xz \
 && rm gcc-${GCC_VERSION}.tar.xz

# GCC ОБЯЗАТЕЛЬНО собирается в отдельной директории (не в source tree)
RUN mkdir build && cd build \
 && ../gcc-${GCC_VERSION}/configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --libexecdir=/usr/lib/x86_64-linux-gnu \
      --disable-bootstrap \
      --disable-multilib \
      --enable-languages=c,c++ \
      --enable-shared \
      --enable-threads=posix \
      --with-system-zlib \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Удаляем документацию и info-файлы для уменьшения размера
# RUN rm -rf /out/usr/share/man /out/usr/share/info /out/usr/share/locale \
#  && cp -a /out/* / \
#  && ldconfig \
#  && rm -rf /build/*
#### compilation ####

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

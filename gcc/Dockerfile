# Сборка GCC (GNU Compiler Collection) из исходников.
# GMP, MPFR, MPC собираются in-tree (помещаются в дерево исходников GCC).
# Результат: /out — полный компилятор GCC (gcc, g++, runtime-библиотеки).
#   /out/usr/bin/gcc                          — компилятор C
#   /out/usr/bin/g++                          — компилятор C++
#   /out/usr/lib/x86_64-linux-gnu/libgcc_s.so — runtime-библиотека
#   /out/usr/lib/x86_64-linux-gnu/libstdc++.so — C++ runtime
# Использование: tar xzf gcc-<version>.tar.gz -C / && ldconfig

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GCC_VERSION=8.5.0
ARG GMP_VERSION=6.2.1
ARG MPFR_VERSION=4.2.1
ARG MPC_VERSION=1.3.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        flex \
        texinfo \
        file \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/gcc-${GCC_VERSION}.tar.xz /build/
COPY artifacts/src/gmp-${GMP_VERSION}.tar.xz /build/
COPY artifacts/src/mpfr-${MPFR_VERSION}.tar.xz /build/
COPY artifacts/src/mpc-${MPC_VERSION}.tar.gz /build/

RUN tar xJf gcc-${GCC_VERSION}.tar.xz \
 && rm gcc-${GCC_VERSION}.tar.xz

# In-tree: помещаем GMP, MPFR, MPC в дерево исходников GCC.
# GCC configure автоматически найдёт и соберёт их вместе с компилятором.
RUN tar xJf gmp-${GMP_VERSION}.tar.xz \
 && mv gmp-${GMP_VERSION} gcc-${GCC_VERSION}/gmp \
 && rm gmp-${GMP_VERSION}.tar.xz

RUN tar xJf mpfr-${MPFR_VERSION}.tar.xz \
 && mv mpfr-${MPFR_VERSION} gcc-${GCC_VERSION}/mpfr \
 && rm mpfr-${MPFR_VERSION}.tar.xz

RUN tar xzf mpc-${MPC_VERSION}.tar.gz \
 && mv mpc-${MPC_VERSION} gcc-${GCC_VERSION}/mpc \
 && rm mpc-${MPC_VERSION}.tar.gz

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
RUN rm -rf /out/usr/share/man /out/usr/share/info /out/usr/share/locale

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка libstdc++ из исходников GCC.
# GMP, MPFR, MPC собираются in-tree (помещаются в дерево исходников GCC).
# Результат: /out — только .so файлы libstdc++ (runtime).
#   /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.25  — основная библиотека
# Использование: COPY --from=libstdcxx /out / && ldconfig

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LIBSTDCXX_VERSION=8.5.0
ARG GMP_VERSION=6.2.1
ARG MPFR_VERSION=4.2.1
ARG MPC_VERSION=1.3.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/gcc-${LIBSTDCXX_VERSION}.tar.xz /build/
COPY artifacts/src/gmp-${GMP_VERSION}.tar.xz /build/
COPY artifacts/src/mpfr-${MPFR_VERSION}.tar.xz /build/
COPY artifacts/src/mpc-${MPC_VERSION}.tar.gz /build/

RUN tar xJf gcc-${LIBSTDCXX_VERSION}.tar.xz \
 && rm gcc-${LIBSTDCXX_VERSION}.tar.xz

# In-tree: помещаем GMP, MPFR, MPC в дерево исходников GCC
RUN tar xJf gmp-${GMP_VERSION}.tar.xz \
 && mv gmp-${GMP_VERSION} gcc-${LIBSTDCXX_VERSION}/gmp \
 && rm gmp-${GMP_VERSION}.tar.xz

RUN tar xJf mpfr-${MPFR_VERSION}.tar.xz \
 && mv mpfr-${MPFR_VERSION} gcc-${LIBSTDCXX_VERSION}/mpfr \
 && rm mpfr-${MPFR_VERSION}.tar.xz

RUN tar xzf mpc-${MPC_VERSION}.tar.gz \
 && mv mpc-${MPC_VERSION} gcc-${LIBSTDCXX_VERSION}/mpc \
 && rm mpc-${MPC_VERSION}.tar.gz

# Конфигурируем GCC полностью, но собираем ТОЛЬКО libstdc++
RUN mkdir build && cd build \
 && ../gcc-${LIBSTDCXX_VERSION}/configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --disable-bootstrap \
      --disable-multilib \
      --enable-languages=c,c++ \
 && make -j$(nproc) all-target-libstdc++-v3 \
 && make DESTDIR=/out install-target-libstdc++-v3

# GCC устанавливает target-библиотеки в lib64, перемещаем в Debian multiarch путь
RUN mkdir -p /stage/usr/lib/x86_64-linux-gnu \
 && cp -a /out/usr/lib/lib64/libstdc++.so* /stage/usr/lib/x86_64-linux-gnu/ \
 && cp -a /out/usr/lib/lib64/libgcc_s.so* /stage/usr/lib/x86_64-linux-gnu/ \
 && rm -rf /out && mv /stage /out

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Унифицированный toolchain: наш GCC + общие build-инструменты + единые CFLAGS.
# Используется как базовый образ для builder-стадии всех библиотечных проектов.
#
# Содержит:
#   - GCC (gcc, g++, libstdc++, libgcc)  — из проекта gcc/
#   - Autotools: make, autoconf, automake, libtool, pkg-config, m4, gettext
#   - Build tools: cmake, meson, ninja-build, binutils, file, patch
#   - Languages: perl, python3, python3-setuptools, python3-jinja2
#   - Misc: flex, gperf, texinfo, xz-utils, groff-base
#   - Унифицированные ENV: CC, CXX, CFLAGS, CXXFLAGS, LDFLAGS
#
# Использование в проектах:
#   ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
#   FROM ${TOOLCHAIN_IMAGE} AS builder
#   ...
#   FROM ${BASE_IMAGE}
#   COPY --from=builder /out /out

ARG BASE_IMAGE=astra-linux:2.12
ARG GCC_IMAGE=gcc:8.5.0-r1-build

FROM ${GCC_IMAGE} AS gcc-build

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Общие build-инструменты из apt (НЕ компиляторы — gcc из нашей сборки)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        autoconf \
        automake \
        libtool \
        pkg-config \
        binutils \
        file \
        perl \
        texinfo \
        flex \
        patch \
        cmake \
        gperf \
        gettext \
        autopoint \
        xz-utils \
        m4 \
        python3 \
        python3-setuptools \
        python3-jinja2 \
        meson \
        ninja-build \
        groff-base \
        bzip2 \
        zlib1g-dev \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
    && rm -rf /var/lib/apt/lists/*

# Наш GCC (замена системного gcc 6.3)
COPY --from=gcc-build /out/ /
RUN ldconfig

# Унифицированные флаги компиляции для всех проектов
ENV CC=gcc \
    CXX=g++ \
    CFLAGS="-O2 -fPIC -pipe" \
    CXXFLAGS="-O2 -fPIC -pipe" \
    LDFLAGS="" \
    PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"

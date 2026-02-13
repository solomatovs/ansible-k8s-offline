# Унифицированный toolchain: наш GCC + общие build-инструменты + единые CFLAGS.
# Используется как шаблонный регион для builder-стадии всех библиотечных проектов.
#
# Содержит:
#   - Bootstrap: build-essential (системный gcc для компиляции нашего gcc)
#   - GCC (gcc, g++, libstdc++, libgcc)  — из исходников (#### <gcc:8.5.0:compilation> ####)
#   - Autotools: make, autoconf, automake, libtool, pkg-config, m4, gettext
#   - Build tools: cmake, meson, ninja-build, binutils, file, patch
#   - Languages: perl, python3, python3-setuptools, python3-jinja2
#   - Misc: flex, gperf, texinfo, xz-utils, groff-base
#   - Унифицированные ENV: CC, CXX, CFLAGS, CXXFLAGS, LDFLAGS
#
# Использование в проектах:
#   FROM ${BASE_IMAGE} AS builder
#   #### <toolchain-gcc:8.5.0:toolchain> ####
#   ...

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE}

#### toolchain ####
ENV DEBIAN_FRONTEND=noninteractive

# Bootstrap-компилятор (системный gcc) + все build-инструменты одним слоем
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
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

# Наш GCC из исходников (заменяет системный gcc)
#### <gcc:8.5.0:compilation> ####

# Унифицированные флаги компиляции для всех проектов
ENV CC=gcc \
    CXX=g++ \
    CFLAGS="-O2 -fPIC -pipe" \
    CXXFLAGS="-O2 -fPIC -pipe" \
    LDFLAGS="" \
    PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
#### toolchain ####

# Сборка bzip2 из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/bzlib.h
#   /out/usr/lib/x86_64-linux-gnu/libbz2.{a,so*}
# Используется как build-зависимость: dpkg.

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG BZIP2_VERSION=1.0.8


WORKDIR /build

COPY artifacts/src/bzip2-${BZIP2_VERSION}.tar.gz /build/

RUN tar xzf bzip2-${BZIP2_VERSION}.tar.gz \
 && rm bzip2-${BZIP2_VERSION}.tar.gz

WORKDIR /build/bzip2-${BZIP2_VERSION}

# bzip2 Makefile не поддерживает configure — правим через переменные.
# Собираем static-библиотеку
RUN make -j$(nproc) CFLAGS="-O2 -fPIC -Wall" libbz2.a

# Собираем shared-библиотеку через Makefile-libbz2_so
RUN make -f Makefile-libbz2_so CFLAGS="-O2 -fPIC -Wall"

# Ручная установка (bzip2 не имеет DESTDIR)
RUN mkdir -p /out/usr/lib/x86_64-linux-gnu /out/usr/include \
 && cp bzlib.h /out/usr/include/ \
 && cp libbz2.a /out/usr/lib/x86_64-linux-gnu/ \
 && cp -a libbz2.so* /out/usr/lib/x86_64-linux-gnu/ \
 && ldconfig -n /out/usr/lib/x86_64-linux-gnu \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка GNU Gawk из исходников.
# Результат: /out/usr/bin/gawk

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG GAWK_VERSION=5.2.2


WORKDIR /build

COPY artifacts/src/gawk-${GAWK_VERSION}.tar.xz /build/

RUN tar xJf gawk-${GAWK_VERSION}.tar.xz \
 && rm gawk-${GAWK_VERSION}.tar.xz

RUN cd gawk-${GAWK_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make DESTDIR=/out install \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

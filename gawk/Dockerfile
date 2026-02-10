# Сборка GNU Gawk из исходников.
# Результат: /out/usr/bin/gawk

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GAWK_VERSION=5.2.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/gawk-${GAWK_VERSION}.tar.xz /build/

RUN tar xJf gawk-${GAWK_VERSION}.tar.xz \
 && rm gawk-${GAWK_VERSION}.tar.xz

RUN cd gawk-${GAWK_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

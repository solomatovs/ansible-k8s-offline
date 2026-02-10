# Сборка GNU Bison + GNU m4 из исходников.
# Результат: /out/usr/bin/{bison,m4} и /out/usr/share/bison/
# m4 включён т.к. bison вызывает m4 при генерации парсеров.

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG BISON_VERSION=3.8.2
ARG M4_VERSION=1.4.19

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# --- m4 (runtime-зависимость bison) ---
COPY artifacts/src/m4-${M4_VERSION}.tar.xz /build/
RUN tar xJf m4-${M4_VERSION}.tar.xz && rm m4-${M4_VERSION}.tar.xz
RUN cd m4-${M4_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make install \
 && make DESTDIR=/out install

# --- bison ---
COPY artifacts/src/bison-${BISON_VERSION}.tar.xz /build/
RUN tar xJf bison-${BISON_VERSION}.tar.xz && rm bison-${BISON_VERSION}.tar.xz
RUN cd bison-${BISON_VERSION} \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

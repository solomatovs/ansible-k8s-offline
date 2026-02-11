# Сборка libaio (Linux Asynchronous I/O) из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/libaio.h
#   /out/usr/lib/x86_64-linux-gnu/libaio.{a,so*}
# Используется как build-зависимость: libdevmapper (LVM2).

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LIBAIO_VERSION=0.3.113

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/libaio-${LIBAIO_VERSION}.tar.gz /build/

RUN tar xzf libaio-${LIBAIO_VERSION}.tar.gz \
 && rm libaio-${LIBAIO_VERSION}.tar.gz

RUN make -C libaio-${LIBAIO_VERSION} -j$(nproc) \
 && make -C libaio-${LIBAIO_VERSION} \
      prefix=/usr \
      libdir=/usr/lib/x86_64-linux-gnu \
      DESTDIR=/out install

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

# Сборка libaio (Linux Asynchronous I/O) из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/libaio.h
#   /out/usr/lib/x86_64-linux-gnu/libaio.{a,so*}
# Используется как build-зависимость: libdevmapper (LVM2).

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBAIO_VERSION=0.3.113


WORKDIR /build

COPY artifacts/src/libaio-${LIBAIO_VERSION}.tar.gz /build/

RUN mkdir -p libaio-${LIBAIO_VERSION} \
 && tar xzf libaio-${LIBAIO_VERSION}.tar.gz --strip-components=1 -C libaio-${LIBAIO_VERSION} \
 && rm libaio-${LIBAIO_VERSION}.tar.gz

RUN make -C libaio-${LIBAIO_VERSION} -j$(nproc) \
 && make -C libaio-${LIBAIO_VERSION} \
      prefix=/usr \
      libdir=/usr/lib/x86_64-linux-gnu \
      DESTDIR=/out install

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

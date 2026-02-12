# Сборка GNU Bison из исходников.
# m4 доступен из toolchain (apt), отдельная сборка не требуется.
# Результат: /out/usr/bin/bison и /out/usr/share/bison/

ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG BISON_VERSION=3.8.2

WORKDIR /build

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

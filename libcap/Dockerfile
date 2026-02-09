# Сборка статической библиотеки libcap из исходников.
# Результат: /out (prefix=/usr)
#   /out/usr/lib/libcap.a              — статическая библиотека
#   /out/usr/include/sys/capability.h  — заголовочный файл
#   /out/usr/include/sys/securebits.h  — заголовочный файл
# Использование: COPY --from=libcap-astra:2.25-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG LIBCAP_VERSION=2.25

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/src/libcap-${LIBCAP_VERSION}.tar.xz /build/

RUN mkdir -p /build/libcap \
 && tar xJf libcap-${LIBCAP_VERSION}.tar.xz --strip-components=1 -C /build/libcap \
 && rm libcap-${LIBCAP_VERSION}.tar.xz

WORKDIR /build/libcap

# Собираем только библиотеку (без progs и pam_cap)
RUN make -C libcap -j$(nproc) lib=lib prefix=/usr \
 && make -C libcap DESTDIR=/out prefix=/usr lib=lib install \
 && find /out -name '*.so*' -delete

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

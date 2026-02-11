# Сборка libudev из исходников systemd (meson).
# Собираем только libudev — ninja компилирует только библиотечные таргеты.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libudev.{a,so*}           — библиотека
#   /out/usr/include/libudev.h             — заголовочный файл
#   /out/usr/lib/pkgconfig/libudev.pc      — pkg-config
# Используется как build-зависимость: libbtrfs (btrfs-progs).

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG SYSTEMD_VERSION=241
ARG LIBCAP_VERSION=2.25

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        meson \
        ninja-build \
        pkg-config \
        gperf \
        m4 \
        python3 \
        python3-jinja2 \
        gettext \
 && rm -rf /var/lib/apt/lists/*

# C-зависимости из наших сборок (вместо apt -dev пакетов)
COPY artifacts/deps/libcap-${LIBCAP_VERSION}.tar.gz /build/
RUN tar xzf /build/libcap-${LIBCAP_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/libcap-${LIBCAP_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/systemd-${SYSTEMD_VERSION}.tar.gz /build/

RUN mkdir -p /build/systemd \
 && tar xzf systemd-${SYSTEMD_VERSION}.tar.gz --strip-components=1 -C /build/systemd \
 && rm systemd-${SYSTEMD_VERSION}.tar.gz

WORKDIR /build/systemd

RUN meson setup build \
      --prefix=/usr \
      --libdir=/usr/lib \
      -Drootlibdir=/usr/lib \
      -Dstatic-libudev=pic \
      -Dtests=false \
      -Dman=false \
      -Dhtml=false \
 && ninja -C build version.h \
 && ninja -C build libudev.a \
 && SO_TARGET=$(grep -m1 -oP 'build \K\S*libudev\.so\S*(?=\s*:)' build/build.ninja) \
 && { [ -n "$SO_TARGET" ] && ninja -C build "$SO_TARGET" || true; } \
 && mkdir -p /out/usr/lib/pkgconfig /out/usr/include \
 && find build -type f -name 'libudev.a' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && find build -type f -name 'libudev.so.*.*.*' ! -name '*.symbols' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && ( cd /out/usr/lib \
   && SO_REAL=$(ls libudev.so.*.*.* 2>/dev/null | grep -v '\.symbols$' | head -1) \
   && [ -n "$SO_REAL" ] && ln -sf "$SO_REAL" libudev.so.1 && ln -sf libudev.so.1 libudev.so \
   || true ) \
 && find build -name 'libudev.pc' | head -1 | xargs -I{} cp {} /out/usr/lib/pkgconfig/ \
 && cp src/libudev/libudev.h /out/usr/include/

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

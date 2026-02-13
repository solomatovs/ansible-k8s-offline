# Сборка libudev из исходников systemd (meson).
# Собираем только libudev — ninja компилирует только библиотечные таргеты.
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libudev.{a,so*}           — библиотека
#   /out/usr/include/libudev.h             — заголовочный файл
#   /out/usr/lib/pkgconfig/libudev.pc      — pkg-config
# Используется как build-зависимость: libbtrfs (btrfs-progs).

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <bison:3.8.2:compilation> ####
#### <libcap:2.25:compilation> ####
#### <libmount:2.30.2:compilation> ####

#### compilation ####
ARG LIBUDEV_VERSION=241

WORKDIR /build

COPY artifacts/src/systemd-${LIBUDEV_VERSION}.tar.gz /build/

RUN mkdir -p /build/systemd \
 && tar xzf systemd-${LIBUDEV_VERSION}.tar.gz --strip-components=1 -C /build/systemd \
 && rm systemd-${LIBUDEV_VERSION}.tar.gz

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
 && STATIC_TARGET=$(grep -m1 -oP 'build \K\S*libudev[_a-z]*\.a(?=\s*:)' build/build.ninja) \
 && echo "Static target: $STATIC_TARGET" \
 && { [ -n "$STATIC_TARGET" ] && ninja -C build "$STATIC_TARGET" || true; } \
 && SO_TARGET=$(grep -m1 -oP 'build \K\S*libudev\.so\S*(?=\s*:)' build/build.ninja) \
 && echo "SO target: $SO_TARGET" \
 && { [ -n "$SO_TARGET" ] && ninja -C build "$SO_TARGET" || true; } \
 && mkdir -p /out/usr/lib/pkgconfig /out/usr/include \
 && find build -type f -name 'libudev*.a' | head -1 | xargs -I{} cp {} /out/usr/lib/libudev.a \
 && find build -type f -name 'libudev.so.*.*.*' ! -name '*.symbols' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && ( cd /out/usr/lib \
   && SO_REAL=$(ls libudev.so.*.*.* 2>/dev/null | grep -v '\.symbols$' | head -1) \
   && [ -n "$SO_REAL" ] && ln -sf "$SO_REAL" libudev.so.1 && ln -sf libudev.so.1 libudev.so \
   || true ) \
 && find build -name 'libudev.pc' | head -1 | xargs -I{} cp {} /out/usr/lib/pkgconfig/ \
 && cp src/libudev/libudev.h /out/usr/include/ \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

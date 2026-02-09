# Сборка статической библиотеки libsystemd из исходников systemd (meson).
# Собирается минимальная конфигурация — только libsystemd, без демонов и утилит.
# C-зависимости (libcap, libmount, libgcrypt, libgpg-error) подаются как файловые
# зависимости из artifacts/deps/ (make deps).
#
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libsystemd.a            — статическая библиотека
#   /out/usr/include/systemd/*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/libsystemd.pc — pkg-config
# Использование: COPY --from=libsystemd-astra:241-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG SYSTEMD_VERSION=241
ARG LIBCAP_VERSION=2.25
ARG LIBMOUNT_VERSION=2.30.2
ARG GPG_ERROR_VERSION=1.35
ARG GCRYPT_VERSION=1.7.6

ENV DEBIAN_FRONTEND=noninteractive

# systemd v241 требует meson >= 0.46, в Astra Linux 2.12 есть 0.49.0 — совместимо
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

# C-зависимости для сборки (make deps)
COPY artifacts/deps/libcap-astra-${LIBCAP_VERSION}.tar.gz /build/
RUN tar xzf /build/libcap-astra-${LIBCAP_VERSION}.tar.gz -C / \
 && rm /build/libcap-astra-${LIBCAP_VERSION}.tar.gz

COPY artifacts/deps/libmount-astra-${LIBMOUNT_VERSION}.tar.gz /build/
RUN tar xzf /build/libmount-astra-${LIBMOUNT_VERSION}.tar.gz -C / \
 && rm /build/libmount-astra-${LIBMOUNT_VERSION}.tar.gz

COPY artifacts/deps/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz /build/
RUN tar xzf /build/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz -C / \
 && rm /build/libgpg-error-astra-${GPG_ERROR_VERSION}.tar.gz

COPY artifacts/deps/libgcrypt-astra-${GCRYPT_VERSION}.tar.gz /build/
RUN tar xzf /build/libgcrypt-astra-${GCRYPT_VERSION}.tar.gz -C / \
 && rm /build/libgcrypt-astra-${GCRYPT_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/systemd-${SYSTEMD_VERSION}.tar.gz /build/

RUN mkdir -p /build/systemd \
 && tar xzf systemd-${SYSTEMD_VERSION}.tar.gz --strip-components=1 -C /build/systemd \
 && rm systemd-${SYSTEMD_VERSION}.tar.gz

WORKDIR /build/systemd

# Минимальная конфигурация — только libsystemd
# v241 не имеет опций standalone-binaries и userdb (появились позже)
RUN meson setup build \
      --prefix=/usr \
      --libdir=/usr/lib \
      -Drootlibdir=/usr/lib \
      -Dstatic-libsystemd=pic \
      -Ddefault-dnssec=no \
      -Dfirstboot=false \
      -Dhibernate=false \
      -Didn=false \
      -Dimportd=false \
      -Dlogind=false \
      -Dmachined=false \
      -Dnetworkd=false \
      -Dresolve=false \
      -Dsysusers=false \
      -Dtimedated=false \
      -Dtimesyncd=false \
      -Dtmpfiles=false \
      -Dtests=false \
      -Dman=false \
      -Dhtml=false \
 && ninja -C build version.h \
 && ninja -C build libsystemd.a

# Собрать результат: libsystemd.a + заголовки + pkg-config
RUN mkdir -p /out/usr/lib/pkgconfig /out/usr/include/systemd \
 && find build -name 'libsystemd.a' ! -name 'libsystemd_static.a' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && find build -name 'libsystemd.pc' | head -1 | xargs -I{} cp {} /out/usr/lib/pkgconfig/ \
 && cp src/systemd/*.h /out/usr/include/systemd/ \
 && { cp build/src/systemd/*.h /out/usr/include/systemd/ 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

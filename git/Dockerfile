# Сборка git из исходников.
# C-зависимости (curl, zlib, openssl) подаются как файловые зависимости из artifacts/deps/ (make deps).
# Результат: /out (--prefix=/usr)
#   /out/usr/bin/git                   — бинарник git
#   /out/usr/libexec/git-core/*        — вспомогательные утилиты
#   /out/usr/share/git-core/*          — шаблоны
# Использование: COPY --from=git:2.42.0-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG GIT_VERSION=2.42.0
ARG CURL_VERSION=8.4.0
ARG ZLIB_VERSION=1.3.1
ARG OPENSSL_VERSION=1.1.1w

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        gettext \
        autoconf \
 && rm -rf /var/lib/apt/lists/*

# C-зависимости для сборки (make deps)
COPY artifacts/deps/curl-${CURL_VERSION}.tar.gz /build/
RUN tar xzf /build/curl-${CURL_VERSION}.tar.gz -C / \
 && rm /build/curl-${CURL_VERSION}.tar.gz

COPY artifacts/deps/zlib-${ZLIB_VERSION}.tar.gz /build/
RUN tar xzf /build/zlib-${ZLIB_VERSION}.tar.gz -C / \
 && rm /build/zlib-${ZLIB_VERSION}.tar.gz

COPY artifacts/deps/openssl-${OPENSSL_VERSION}.tar.gz /build/
RUN tar xzf /build/openssl-${OPENSSL_VERSION}.tar.gz -C / \
 && rm /build/openssl-${OPENSSL_VERSION}.tar.gz

WORKDIR /build

COPY artifacts/src/git-${GIT_VERSION}.tar.gz /build/

RUN tar xzf git-${GIT_VERSION}.tar.gz \
 && cd git-${GIT_VERSION} \
 && make configure \
 && ./configure --prefix=/usr \
       --with-curl=/usr \
       --with-openssl=/usr \
       --with-zlib=/usr \
       --without-tcltk \
 && make -j$(nproc) NO_TCLTK=1 all \
 && make NO_TCLTK=1 DESTDIR=/out install \
 && { rm -rf /out/usr/share/man /out/usr/share/doc 2>/dev/null || true; }

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

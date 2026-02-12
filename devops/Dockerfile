# DevOps-образ: rootless buildah + dpkg + git + golang + gcc + curl на Astra Linux.
# Объединяет артефакты из проектов dpkg/, buildah/, git/, golang/, gcc/, curl/.
# Бинарные зависимости подаются как файлы из artifacts/deps/ (make deps).
#
# Образы (COPY --from в Dockerfile):
#   - glibc:2.28-build          — runtime .so + dev-файлы (замена libc6-dev)
#   - libstdcxx:8.5.0-build     — C++ runtime
#   - gcc:8.5.0-build           — компилятор (замена apt gcc)
#   - curl + 12 runtime deps    — CLI + shared libraries (замена apt curl)
# Зависимости (должны быть извлечены до сборки: make deps):
#   - artifacts/deps/dpkg-1.23.5.tar.gz
#   - artifacts/deps/buildah-1.38.0.tar.gz
#   - artifacts/deps/git-2.42.0.tar.gz
#   - artifacts/deps/golang-1.24.5.tar.gz
#
# Образ не привязан к конкретному пользователю —
# можно запустить под любым uid если смонтировать:
#   - /etc/passwd и /etc/group с именем пользователя, uid и gid
#   - /etc/subuid и /etc/subgid с split-диапазонами (пропустить собственный uid)

ARG BASE_IMAGE=astra-linux:2.12
ARG GLIBC_VERSION=2.28
ARG LIBSTDCXX_VERSION=8.5.0
ARG GCC_VERSION=8.5.0
ARG CURL_VERSION=8.4.0
ARG ZLIB_VERSION=1.3.1
ARG OPENSSL_VERSION=1.1.1w
ARG KERBEROS_VERSION=1.20.1
ARG NGHTTP2_VERSION=1.58.0
ARG OPENLDAP_VERSION=2.6.6
ARG LIBSSH2_VERSION=1.11.0
ARG LIBUNISTRING_VERSION=1.1
ARG LIBIDN2_VERSION=2.3.4
ARG ZSTD_VERSION=1.5.5
ARG BROTLI_VERSION=1.1.0
ARG NGHTTP3_VERSION=1.1.0
ARG NGTCP2_VERSION=1.2.0
ARG DPKG_VERSION=1.23.5
ARG BUILDAH_VERSION=1.38.0
ARG GIT_VERSION=2.42.0
ARG GOLANG_VERSION=1.24.5
ARG RELEASE_INFO=""

# Ссылки на pre-built образы (COPY --from не запускает код, нет segfault)
FROM glibc:${GLIBC_VERSION}-build       AS glibc
FROM libstdcxx:${LIBSTDCXX_VERSION}-build AS libstdcxx
FROM gcc:${GCC_VERSION}-build           AS gcc-build

# curl + все его runtime-зависимости (shared libraries)
FROM zlib:${ZLIB_VERSION}-build               AS zlib-build
FROM openssl:${OPENSSL_VERSION}-build         AS openssl-build
FROM kerberos:${KERBEROS_VERSION}-build       AS kerberos-build
FROM nghttp2:${NGHTTP2_VERSION}-build         AS nghttp2-build
FROM openldap:${OPENLDAP_VERSION}-build       AS openldap-build
FROM libssh2:${LIBSSH2_VERSION}-build         AS libssh2-build
FROM libunistring:${LIBUNISTRING_VERSION}-build AS libunistring-build
FROM libidn2:${LIBIDN2_VERSION}-build         AS libidn2-build
FROM zstd:${ZSTD_VERSION}-build               AS zstd-build
FROM brotli:${BROTLI_VERSION}-build           AS brotli-build
FROM nghttp3:${NGHTTP3_VERSION}-build         AS nghttp3-build
FROM ngtcp2:${NGTCP2_VERSION}-build           AS ngtcp2-build
FROM curl:${CURL_VERSION}-build               AS curl-build

# --- Промежуточный этап: бандл curl + все runtime shared libraries ---
FROM ${BASE_IMAGE} AS curl-bundle
COPY --from=zlib-build         /out/ /bundle/
COPY --from=openssl-build      /out/ /bundle/
COPY --from=kerberos-build     /out/ /bundle/
COPY --from=nghttp2-build      /out/ /bundle/
COPY --from=openldap-build     /out/ /bundle/
COPY --from=libssh2-build      /out/ /bundle/
COPY --from=libunistring-build /out/ /bundle/
COPY --from=libidn2-build      /out/ /bundle/
COPY --from=zstd-build         /out/ /bundle/
COPY --from=brotli-build       /out/ /bundle/
COPY --from=nghttp3-build      /out/ /bundle/
COPY --from=ngtcp2-build       /out/ /bundle/
COPY --from=curl-build         /out/ /bundle/

# =============================================================================
# Основной образ
# =============================================================================
FROM ${BASE_IMAGE}

ARG GLIBC_VERSION
ARG LIBSTDCXX_VERSION
ARG GCC_VERSION
ARG CURL_VERSION
ARG DPKG_VERSION
ARG BUILDAH_VERSION
ARG GIT_VERSION
ARG GOLANG_VERSION
ARG RELEASE_INFO

ENV DEBIAN_FRONTEND=noninteractive

# --- dpkg (rootless-патченный, статические бинарники) ---
COPY artifacts/deps/dpkg-${DPKG_VERSION}.tar.gz /build/
RUN tar xzf /build/dpkg-${DPKG_VERSION}.tar.gz -C / \
 && rm /build/dpkg-${DPKG_VERSION}.tar.gz

# --- buildah (статический бинарник) ---
COPY artifacts/deps/buildah-${BUILDAH_VERSION}.tar.gz /build/
RUN tar xzf /build/buildah-${BUILDAH_VERSION}.tar.gz -C / \
 && rm /build/buildah-${BUILDAH_VERSION}.tar.gz

# --- git (статический бинарник из нашей сборки) ---
COPY artifacts/deps/git-${GIT_VERSION}.tar.gz /build/
RUN tar xzf /build/git-${GIT_VERSION}.tar.gz -C / \
 && rm /build/git-${GIT_VERSION}.tar.gz

# --- golang ---
COPY artifacts/deps/golang-${GOLANG_VERSION}.tar.gz /build/
RUN tar xzf /build/golang-${GOLANG_VERSION}.tar.gz -C / \
 && rm /build/golang-${GOLANG_VERSION}.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# --- Runtime-зависимости (только то, чего нет в наших проектах) ---
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        uidmap \
        libcap2-bin \
        ca-certificates \
        make \
        binutils \
        strace \
    && rm -rf /var/lib/apt/lists/*

# --- glibc 2.28 (runtime .so + dev: headers, .a, .o — замена libc6-dev) ---
# ВАЖНО: glibc заменяется ПОСЛЕ apt-get install, т.к. apt устанавливает libc6 (2.24)
# из репозитория и перезаписал бы наши файлы.
# COPY --from безопасно заменяет .so файлы без запуска процессов в контейнере.
COPY --from=glibc /out/lib/ /lib/
COPY --from=glibc /out/usr/lib/ /usr/lib/
COPY --from=glibc /out/usr/include/ /usr/include/
# sln — статический бинарник из glibc для безопасного обновления symlinks.
# ELF PT_INTERP в Astra указывает на /lib64/ld-linux-x86-64.so.2 → ld-2.24.so.
# Без обновления этого symlink ядро загружает старый ld-2.24 + новый libc-2.28 = segfault.
COPY --from=glibc /out/sbin/sln /tmp/sln
RUN ["/tmp/sln", "/lib/x86_64-linux-gnu/ld-2.28.so", "/lib64/ld-linux-x86-64.so.2"]
RUN ldconfig

# --- libstdc++ (GLIBCXX_3.4.25 для VSCode Server / Node.js 20+) ---
COPY --from=libstdcxx /out/usr/lib/ /usr/lib/

# --- gcc (компилятор из нашей сборки — замена apt gcc) ---
COPY --from=gcc-build /out/ /

# --- curl + все runtime shared libraries (замена apt curl) ---
COPY --from=curl-bundle /bundle/ /

RUN ldconfig && rm -f /tmp/sln

# --- Конфигурация buildah ---
RUN mkdir -p /etc/containers \
 && printf '[engine]\ncgroup_manager = "cgroupfs"\n' \
        > /etc/containers/containers.conf \
 && printf 'unqualified-search-registries = ["docker.io"]\n' \
        > /etc/containers/registries.conf \
 && printf '[storage]\ndriver = "vfs"\nrunroot = "/run/containers/storage"\ngraphroot = "/var/lib/containers/storage"\n' \
        > /etc/containers/storage.conf \
 && printf '/run/secrets/etc-pki-entitlement:/run/secrets/etc-pki-entitlement\n/run/secrets/rhsm:/run/secrets/rhsm\n' \
        > /etc/containers/mounts.conf

# Shared storage locks
RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers \
 && touch /var/lib/shared/overlay-images/images.lock \
          /var/lib/shared/overlay-layers/layers.lock \
          /var/lib/shared/vfs-images/images.lock \
          /var/lib/shared/vfs-layers/layers.lock

# World-writable директории (sticky bit, как /tmp):
# /home               — HOME для любого UID
# /run/containers     — runroot buildah (runtime/lock-файлы)
# /var/lib/containers — graphroot buildah (образы и слои)
# /var/lib/dpkg/*     — dpkg-база (status, info, updates, triggers)
# /var/cache/apt/*    — кэш скачанных пакетов
# /var/lib/apt/*      — списки пакетов и состояние
# /var/log, /var/log/apt — логи dpkg и apt
RUN mkdir -p /var/lib/containers/storage /run/containers/storage \
             /var/cache/apt/archives/partial \
             /var/lib/apt/lists/partial \
             /var/log/apt \
 && chmod 1777 /home \
               /run/containers /run/containers/storage \
               /var/lib/containers /var/lib/containers/storage \
               /var/lib/dpkg \
               /var/lib/dpkg/info \
               /var/lib/dpkg/updates \
               /var/lib/dpkg/triggers \
               /var/cache/apt \
               /var/cache/apt/archives \
               /var/cache/apt/archives/partial \
               /var/lib/apt \
               /var/lib/apt/lists \
               /var/lib/apt/lists/partial \
               /var/log \
               /var/log/apt \
 && chmod a+rw /var/lib/dpkg/status \
               /var/lib/dpkg/available \
 && find /var/lib/dpkg/info -type f -exec chmod a+rw {} + \
 && touch /var/lib/apt/extended_states \
 && chmod a+rw /var/lib/apt/extended_states

# apt: отключить sandbox-переключение на пользователя _apt при скачивании.
# Без root apt не может переключиться на _apt — скачивание будет от текущего uid.
RUN printf 'APT::Sandbox::User "root";\n' > /etc/apt/apt.conf.d/99-rootless

# File capabilities вместо setuid-бита (стандартный подход для rootless buildah)
RUN setcap cap_setuid+ep /usr/bin/newuidmap \
 && setcap cap_setgid+ep /usr/bin/newgidmap \
 && chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap

# subuid/subgid очищаем — правильные значения монтируются при запуске контейнера
RUN : > /etc/subuid && : > /etc/subgid

RUN rm -rf /build

# --- Метаданные профиля ---
RUN printf '%b\n' "${RELEASE_INFO}" > /etc/devops-release

ENV HOME=/home
ENV LANG=C.UTF-8
ENV BUILDAH_ISOLATION=chroot

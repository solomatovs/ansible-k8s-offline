# DevOps-образ: rootless buildah + dpkg + git + golang + gcc + curl на Astra Linux.
# Объединяет артефакты из pre-built образов (COPY --from).
#
# Образы (COPY --from):
#   - glibc:2.28-build          — runtime .so + dev-файлы (замена libc6-dev)
#   - libstdcxx:8.5.0-build     — C++ runtime
#   - gcc:8.5.0-build           — компилятор (замена apt gcc)
#   - git:2.42.0-build          — git + curl + все runtime shared libraries
#   - dpkg:1.23.5-build         — rootless dpkg (статический бинарник)
#   - buildah:1.38.0-build      — buildah (статический бинарник)
#   - golang:1.24.5-build       — Go toolchain
#
# Образ не привязан к конкретному пользователю —
# можно запустить под любым uid если смонтировать:
#   - /etc/passwd и /etc/group с именем пользователя, uid и gid
#   - /etc/subuid и /etc/subgid с split-диапазонами (пропустить собственный uid)

ARG BASE_IMAGE=astra-linux:2.12
ARG GLIBC_IMAGE
ARG LIBSTDCXX_IMAGE
ARG GCC_IMAGE
ARG GIT_IMAGE
ARG DPKG_IMAGE
ARG BUILDAH_IMAGE
ARG GOLANG_IMAGE

# Ссылки на pre-built образы
FROM ${GLIBC_IMAGE}    AS glibc-build
FROM ${LIBSTDCXX_IMAGE} AS libstdcxx-build
FROM ${GCC_IMAGE}      AS gcc-build
FROM ${GIT_IMAGE}      AS git-build
FROM ${DPKG_IMAGE}     AS dpkg-build
FROM ${BUILDAH_IMAGE}  AS buildah-build
FROM ${GOLANG_IMAGE}   AS golang-build

# =============================================================================
# Основной образ
# =============================================================================
FROM ${BASE_IMAGE}

ARG RELEASE_INFO=""

ENV DEBIAN_FRONTEND=noninteractive

# --- dpkg (rootless-патченный, статические бинарники) ---
COPY --from=dpkg-build /out/ /

# --- buildah (статический бинарник) ---
COPY --from=buildah-build /out/ /

# --- git + curl + все runtime shared libraries ---
# git-build содержит git, curl и все C-библиотеки (zlib, openssl, kerberos,
# nghttp2, openldap, libssh2, libunistring, libidn2, zstd, brotli, nghttp3, ngtcp2)
COPY --from=git-build /out/ /

# --- golang ---
COPY --from=golang-build /out/ /

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
COPY --from=glibc-build /out/lib/ /lib/
COPY --from=glibc-build /out/usr/lib/ /usr/lib/
COPY --from=glibc-build /out/usr/include/ /usr/include/
# sln — статический бинарник из glibc для безопасного обновления symlinks.
# ELF PT_INTERP в Astra указывает на /lib64/ld-linux-x86-64.so.2 → ld-2.24.so.
# Без обновления этого symlink ядро загружает старый ld-2.24 + новый libc-2.28 = segfault.
COPY --from=glibc-build /out/sbin/sln /tmp/sln
RUN ["/tmp/sln", "/lib/x86_64-linux-gnu/ld-2.28.so", "/lib64/ld-linux-x86-64.so.2"]
RUN ldconfig

# --- libstdc++ (GLIBCXX_3.4.25 для VSCode Server / Node.js 20+) ---
COPY --from=libstdcxx-build /out/usr/lib/ /usr/lib/

# --- gcc (компилятор из нашей сборки — замена apt gcc) ---
COPY --from=gcc-build /out/ /

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

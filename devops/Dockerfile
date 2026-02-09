# DevOps-образ: rootless buildah + dpkg + golang на Astra Linux.
# Объединяет артефакты из проектов dpkg/, buildah/ и golang/.
#
# Зависимости (должны быть собраны до сборки этого образа):
#   - dpkg-astra:1.23.5-build      (make -C dpkg build)
#   - buildah-astra:v1.38.0-build   (make -C buildah build-astra)
#   - golang-astra:go1.24.5-build   (make -C golang build-latest)
#
# Образ не привязан к конкретному пользователю —
# можно запустить под любым uid если смонтировать:
#   - /etc/passwd и /etc/group с именем пользователя, uid и gid
#   - /etc/subuid и /etc/subgid с split-диапазонами (пропустить собственный uid)

ARG BASE_IMAGE=astra-linux:2.12
ARG DPKG_IMAGE=dpkg-astra:1.23.5-build
ARG BUILDAH_IMAGE=buildah-astra:v1.38.0-build
ARG GO_IMAGE=golang-astra:go1.24.5-build

FROM ${DPKG_IMAGE} AS dpkg
FROM ${BUILDAH_IMAGE} AS buildah
FROM ${GO_IMAGE} AS golang

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# --- dpkg (rootless-патченный, статические бинарники) ---
COPY --from=dpkg /out /

# --- buildah (статический бинарник) ---
COPY --from=buildah /out/usr/bin/buildah /usr/bin/buildah

# --- golang ---
COPY --from=golang /out/usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# --- Runtime-зависимости ---
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        uidmap \
        libcap2-bin \
        ca-certificates \
        make \
        curl \
        git \
        strace \
    && rm -rf /var/lib/apt/lists/*

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
RUN mkdir -p /var/lib/containers/storage /run/containers/storage \
 && chmod 1777 /home \
               /run/containers /run/containers/storage \
               /var/lib/containers /var/lib/containers/storage

# File capabilities вместо setuid-бита (стандартный подход для rootless buildah)
RUN setcap cap_setuid+ep /usr/bin/newuidmap \
 && setcap cap_setgid+ep /usr/bin/newgidmap \
 && chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap

# subuid/subgid очищаем — правильные значения монтируются при запуске контейнера
RUN : > /etc/subuid && : > /etc/subgid

ENV HOME=/home
ENV LANG=C.UTF-8
ENV BUILDAH_ISOLATION=chroot

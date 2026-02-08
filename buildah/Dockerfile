# syntax=docker/dockerfile:1
# Базовый образ: rootless buildah на Debian Bookworm
#
# Образ не привязан к конкретному пользователю — buildah работает
# под любым UID благодаря:
#   - nss_wrapper подставляет запись в passwd/group для неизвестного UID
#   - HOME, graphroot, runroot с правами 1777 (sticky bit, как /tmp)
FROM debian:bookworm-slim

# Установка зависимостей
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        buildah \
        libcap2-bin \
        libnss-wrapper \
        ca-certificates \
        strace \
    && rm -rf /var/lib/apt/lists/*

# Конфигурация buildah, nss_wrapper, права доступа
RUN <<'SCRIPT'
set -e

# --- Глобальная конфигурация buildah ---

cat > /etc/containers/containers.conf <<'EOF'
[engine]
cgroup_manager = "cgroupfs"
EOF

cat > /etc/containers/registries.conf <<'EOF'
unqualified-search-registries = ["docker.io"]
EOF

cat > /etc/containers/storage.conf <<'EOF'
[storage]
driver = "vfs"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"
EOF

# Setup internal Buildah to pass secrets/subscriptions down from host to internal container
cat > /etc/containers/mounts.conf <<'EOF'
/run/secrets/etc-pki-entitlement:/run/secrets/etc-pki-entitlement
/run/secrets/rhsm:/run/secrets/rhsm
EOF

# Shared storage locks
mkdir -p /var/lib/shared/overlay-images \
         /var/lib/shared/overlay-layers \
         /var/lib/shared/vfs-images \
         /var/lib/shared/vfs-layers
touch /var/lib/shared/overlay-images/images.lock \
      /var/lib/shared/overlay-layers/layers.lock \
      /var/lib/shared/vfs-images/images.lock \
      /var/lib/shared/vfs-layers/layers.lock

# World-writable директории (sticky bit, как /tmp):
# /home               — HOME для любого UID (vscode-server, .config, .local и т.д.)
# /run/containers     — runroot buildah (runtime/lock-файлы)
# /var/lib/containers — graphroot buildah (образы и слои)
mkdir -p /var/lib/containers/storage /run/containers/storage
chmod 1777 /home \
           /run/containers /run/containers/storage \
           /var/lib/containers /var/lib/containers/storage

# В Docker-контейнерах setuid-бит не работает (seccomp/runtime ограничения).
# File capabilities — стандартный подход из официального Fedora buildah-образа.
setcap cap_setuid+ep /usr/bin/newuidmap
setcap cap_setgid+ep /usr/bin/newgidmap
chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap

# --- nss_wrapper: поддержка произвольного UID ---
# nss_wrapper через LD_PRELOAD перехватывает вызовы getpwuid/getgrnam и подставляет
# записи из собственных файлов вместо /etc/passwd и /etc/group.
# Это позволяет buildah (и другим утилитам) видеть пользователя без модификации /etc/passwd.
#
# ВАЖНО: /etc/ld.so.preload вместо LD_PRELOAD env var.
# newuidmap/newgidmap имеют file capabilities → ядро включает secure-exec
# и сбрасывает LD_PRELOAD. Но /etc/ld.so.preload является системным файлом
# и загружается ВСЕГДА, даже для setuid/capabilities бинарников.

# Архитектурно-независимый симлинк
ln -s "$(find /usr/lib -name 'libnss_wrapper.so' -print -quit)" /usr/local/lib/libnss_wrapper.so

# Системный preload — работает для ВСЕХ бинарников, включая newuidmap/newgidmap
echo /usr/local/lib/libnss_wrapper.so > /etc/ld.so.preload

# Записываемые копии passwd/group для nss_wrapper
mkdir -p /var/lib/nss_wrapper
cp /etc/passwd /var/lib/nss_wrapper/passwd
cp /etc/group  /var/lib/nss_wrapper/group
chmod a+w /var/lib/nss_wrapper/passwd /var/lib/nss_wrapper/group

# subuid/subgid очищаем — внутри Docker-контейнера доступен только текущий UID.
# Многодиапазонные маппинги (builder:1:999 и т.д.) невозможны: ядро отвергает
# запись в uid_map/gid_map для UID, не замапленных во внешнем user namespace.
# Без записей buildah сразу использует single mapping (0 → текущий UID) без WARN.
: > /etc/subuid
: > /etc/subgid
SCRIPT

VOLUME /var/lib/containers

ENV HOME=/home
ENV LANG=C.UTF-8
ENV BUILDAH_ISOLATION=chroot
ENV _BUILDAH_STARTED_IN_USERNS=1
ENV NSS_WRAPPER_PASSWD=/var/lib/nss_wrapper/passwd
ENV NSS_WRAPPER_GROUP=/var/lib/nss_wrapper/group

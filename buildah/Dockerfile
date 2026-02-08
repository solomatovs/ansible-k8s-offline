# syntax=docker/dockerfile:1
# Базовый образ: rootless buildah на Debian Bookworm
#
# Образ не привязан к конкретному пользователю
# можно запустить под любым uid если смонтировать:
#   - /etc/passwd и /etc/group где будет указано имя пользователя, uid и gid стартового процесса
#   - /etc/subuid и /etc/subgid где будет указаны split-диапазоны (нужно пропустить собственный uid запускаемого процесса)
# папки: HOME, graphroot, runroot с правами 1777 (sticky bit, как /tmp)

# К примеру, для пользователя builder с uid: 1001 и gid: 1001 вот так вычисляется subuid и subgid:
# /etc/sub{u,g}id
#   builder:1:N-1         → subordinate UIDs от 1 до N-1
#   builder:N+1:65535-N   → subordinate UIDs от N+1 до 65535
# 
# Примеры файлов, которые нужно смонтировать при запуске контейнера для этого пользователя builder:
# /etc/subuid:
# builder:1:1000
# builder:1002:64534

# /etc/subgid:
# builder:1:1000
# builder:1002:64534

# /etc/passwd:
# root:x:0:0:root:/root:/bin/bash
# builder:x:1001:1001:builder:/home:/bin/bash
# 
# /etc/group:
# root:x:0:
# builder:x:1001:
FROM debian:bookworm-slim

# Установка зависимостей
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        buildah \
        libcap2-bin \
        ca-certificates \
        make \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Конфигурация buildah, права доступа
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

# subuid/subgid очищаем — правильные значения монтируются при запуске контейнера.
# Формат для UID N (пропускаем сам N, чтобы избежать EINVAL в newuidmap):
#   builder:1:N-1         → subordinate UIDs от 1 до N-1
#   builder:N+1:65535-N   → subordinate UIDs от N+1 до 65535
: > /etc/subuid
: > /etc/subgid
SCRIPT

ENV HOME=/home
ENV LANG=C.UTF-8
ENV BUILDAH_ISOLATION=chroot

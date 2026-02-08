ARG BUILDAH_IMAGE=buildah-rootless:local
ARG DPKG_IMAGE=dpkg-rootless:local
FROM ${DPKG_IMAGE} AS dpkg
FROM ${BUILDAH_IMAGE}

# Патченный dpkg для rootless apt
COPY --from=dpkg /out /

# Разрешаем пользователю использовать apt/dpkg без sudo.
# Рекурсивно chown, но пропускаем readonly.
USER root
ARG USER_UID=1000
ARG USER_GID=1000
ENV CHOWN_DIRS="/usr /var /etc /opt"
RUN <<EOF
    find $CHOWN_DIRS -exec sh -c '
    for f; do
        if [ -w "$f" ] || [ -d "$f" ]; then
            chown ${USER_UID}:${USER_GID} "$f" 2>/dev/null || true
        fi
    done
' sh {} +
EOF

# setcap заново — chown сбрасывает capabilities
RUN setcap cap_setuid+ep /usr/bin/newuidmap \
 && setcap cap_setgid+ep /usr/bin/newgidmap

USER ${USER_UID}

# Проверяем, что патченный dpkg работает
RUN /usr/bin/dpkg --version

# Дополнительные runtime-пакеты для ansible-проекта
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
        make \
        python3 \
        python3-pip \
        python3-venv \
        strace \
    && rm -rf /var/lib/apt/lists/*

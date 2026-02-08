FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем зависимости для сборки dpkg
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    xz-utils \
    pkg-config \
    libbz2-dev \
    liblzma-dev \
    libzstd-dev \
    libselinux1-dev \
    libacl1-dev \
    libcap-dev \
    libncurses-dev \
    libmd-dev \
    gettext \
    perl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Скачиваем исходники dpkg (native package)
RUN wget http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_1.23.5.tar.xz \
 && tar -xf dpkg_1.23.5.tar.xz

WORKDIR /build/dpkg-1.23.5

# Патчим проверку UID при открытии базы dpkg
RUN sed -i 's/if (getuid() || geteuid())/if (0)/' lib/dpkg/dbmodify.c

# Патчим chown: uid:gid из tar-заголовка (.deb хранит root:root)
# подменяем на uid:gid текущего пользователя, если не root
RUN sed -i 's/nodestat = ti->stat;/nodestat = ti->stat; if (getuid() != 0) { nodestat.uid = getuid(); nodestat.gid = getgid(); }/' src/main/archives.c

# Конфигурируем и собираем
RUN ./configure \
      --prefix=/usr \
      --localstatedir=/var \
      --sysconfdir=/etc \
      --disable-static \
 && make -j$(nproc)

# Устанавливаем во временный каталог
RUN make DESTDIR=/out install

# --------------------------------------------------

# Минимальный рантайм-образ
FROM debian:bookworm-slim AS devcontainer
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN addgroup --gid ${USER_GID} ${USERNAME} \
    && adduser --disabled-password --uid ${USER_UID} --gid ${USER_GID} --home "/home/${USERNAME}" --shell /bin/bash ${USERNAME} \
    && addgroup --system crontab

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt -y install --no-install-recommends \
        strace \
        cron \
        ssl-cert \
        ca-certificates \
        make \
        buildah \
        libcap2-bin \
        python3

COPY buildah/policy.json /etc/containers/policy.json
COPY buildah/storage.conf /etc/containers/storage.conf
COPY --from=0 /out /


# Разрешаем пользователю использовать apt/dpkg без sudo.
# Один chown после всех COPY, чтобы не дублировать.
# Определяем каталоги, где обычно есть writable файлы
ENV CHOWN_DIRS="/usr /var /etc /opt"

# Рекурсивно chown, но пропускаем readonly
RUN <<EOF
    find $CHOWN_DIRS -exec sh -c '
    for f; do
        if [ -w "$f" ] || [ -d "$f" ]; then
            chown ${USER_UID}:${USER_GID} "$f" 2>/dev/null || true
        fi
    done
' sh {} +
EOF

# В Docker-контейнерах setuid-бит не работает для записи в /proc/PID/uid_map
# (seccomp/runtime ограничения). File capabilities (filecaps) работают.
# Это стандартный подход из официального Fedora buildah-образа.
RUN setcap cap_setuid+ep /usr/bin/newuidmap \
 && setcap cap_setgid+ep /usr/bin/newgidmap \
 && chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap

ENV HOME=/home/${USERNAME}

USER ${USERNAME}

RUN /usr/bin/dpkg --version

ENTRYPOINT ["/bin/bash"]

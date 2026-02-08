# Сборка dpkg с патчами для rootless-установки пакетов.
# Результат: /out (--prefix=/usr, --localstatedir=/var, --sysconfdir=/etc)
# Использование: COPY --from=dpkg-rootless:local /out /
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

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

RUN wget http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_1.23.5.tar.xz \
 && tar -xf dpkg_1.23.5.tar.xz

WORKDIR /build/dpkg-1.23.5

# Патч 1: убираем проверку UID при открытии базы dpkg
RUN sed -i 's/if (getuid() || geteuid())/if (0)/' lib/dpkg/dbmodify.c

# Патч 2: подменяем uid:gid из tar-заголовка (.deb хранит root:root)
#          на uid:gid текущего пользователя, если запущен не от root
RUN sed -i 's/nodestat = ti->stat;/nodestat = ti->stat; if (getuid() != 0) { nodestat.uid = getuid(); nodestat.gid = getgid(); }/' src/main/archives.c

RUN ./configure \
      --prefix=/usr \
      --localstatedir=/var \
      --sysconfdir=/etc \
      --disable-static \
 && make -j$(nproc)

RUN make DESTDIR=/out install

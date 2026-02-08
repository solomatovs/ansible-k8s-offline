# Сборка dpkg с патчами для rootless-установки пакетов.
# Результат: /out (--prefix=/usr, --localstatedir=/var, --sysconfdir=/etc)
# Использование: COPY --from=dpkg-rootless:local /out /
# FROM debian:bookworm
FROM localhost/astra-linux:2.12

ENV DEBIAN_FRONTEND=noninteractive

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
        build-essential \
        wget \
        xz-utils \
        pkg-config \
        libbz2-dev \
        liblzma-dev \
        libzstd-dev \
        # libmd-dev — отсутствует в Astra Linux, собираем из исходников ниже
        perl \
        ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Сборка libmd из исходников (в Astra Linux 2.12 пакет libmd-dev отсутствует,
# а dpkg 1.23.5 требует md5.h / MD5Init из libmd)
RUN wget https://archive.hadrons.org/software/libmd/libmd-1.1.0.tar.xz \
 && tar -xf libmd-1.1.0.tar.xz \
 && cd libmd-1.1.0 \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make install \
 && ldconfig

RUN wget http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_1.23.5.tar.xz \
 && tar -xf dpkg_1.23.5.tar.xz

WORKDIR /build/dpkg-1.23.5

# Патч 1: убираем проверку UID при открытии базы dpkg
RUN sed -i 's/if (getuid() || geteuid())/if (0)/' lib/dpkg/dbmodify.c

# Патч 2: подменяем uid:gid из tar-заголовка (.deb хранит root:root)
#          на uid:gid текущего пользователя, если запущен не от root
RUN sed -i 's/nodestat = ti->stat;/nodestat = ti->stat; if (getuid() != 0) { nodestat.uid = getuid(); nodestat.gid = getgid(); }/' src/main/archives.c

# Патч 3: configure использует dpkg-architecture.pl для определения архитектуры,
# но скрипт требует Perl >= 5.36, а в Astra Linux только 5.24.
# Хардкодим архитектуру amd64/linux напрямую в configure.
RUN sed -i \
    -e 's|cpu_type=$(PERL=$PERL ${CONFIG_SHELL-/bin/sh} "$srcdir/build-aux/run-script" scripts/dpkg-architecture.pl -t$host -qDEB_HOST_ARCH_CPU 2>/dev/null)|cpu_type=amd64|' \
    -e 's|os_type=$(PERL=$PERL ${CONFIG_SHELL-/bin/sh} "$srcdir/build-aux/run-script" scripts/dpkg-architecture.pl -t$host -qDEB_HOST_ARCH_OS 2>/dev/null)|os_type=linux|' \
    -e 's|dpkg_arch=$(PERL=$PERL ${CONFIG_SHELL-/bin/sh} "$srcdir/build-aux/run-script" scripts/dpkg-architecture.pl -t$host -qDEB_HOST_ARCH 2>/dev/null)|dpkg_arch=amd64|' \
    configure

# --disable-dselect: dselect тоже требует Perl 5.36 при сборке (mkcurkeys.pl)
RUN ./configure PERL=/usr/bin/perl \
      --prefix=/usr \
      --localstatedir=/var \
      --sysconfdir=/etc \
      --disable-static \
      --disable-dselect \
      --disable-nls \
      --disable-start-stop-daemon \
      --disable-update-alternatives \
      --without-libselinux \
 && make -j$(nproc)

RUN make DESTDIR=/out install

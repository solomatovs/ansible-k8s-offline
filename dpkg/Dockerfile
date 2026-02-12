# Сборка полностью статического dpkg с патчами для rootless-установки пакетов.
# Результат: /out (--prefix=/usr, --localstatedir=/var, --sysconfdir=/etc)
# Бинарники не имеют runtime-зависимостей и переносимы между дистрибутивами.
# Использование: COPY --from=dpkg-astra:1.23.5-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG DPKG_VERSION=1.23.5
ARG LIBMD_VERSION=1.1.0
ARG LIBLZMA_VERSION=5.2.2
ARG ZSTD_VERSION=1.5.5
ARG BZIP2_VERSION=1.0.8

# C-зависимости из наших сборок (вместо apt -dev пакетов)
COPY artifacts/deps/bzip2-${BZIP2_VERSION}.tar.gz /build/
RUN tar xzf /build/bzip2-${BZIP2_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/bzip2-${BZIP2_VERSION}.tar.gz

COPY artifacts/deps/libmd-${LIBMD_VERSION}.tar.gz /build/
RUN tar xzf /build/libmd-${LIBMD_VERSION}.tar.gz -C / \
 && rm /build/libmd-${LIBMD_VERSION}.tar.gz

COPY artifacts/deps/liblzma-${LIBLZMA_VERSION}.tar.gz /build/
RUN tar xzf /build/liblzma-${LIBLZMA_VERSION}.tar.gz -C / \
 && rm /build/liblzma-${LIBLZMA_VERSION}.tar.gz

COPY artifacts/deps/zstd-${ZSTD_VERSION}.tar.gz /build/
RUN tar xzf /build/zstd-${ZSTD_VERSION}.tar.gz -C / \
 && rm /build/zstd-${ZSTD_VERSION}.tar.gz

WORKDIR /build

# Копируем предварительно скачанные исходники dpkg (make download)
COPY artifacts/src/dpkg_${DPKG_VERSION}.tar.xz /build/

RUN tar -xf dpkg_${DPKG_VERSION}.tar.xz

# Удаляем все .so и .la для зависимостей — линкер найдёт только .a
# (.la файлы содержат пути к .so, и libtool подставляет их в команду линковки)
# (после распаковки tar.xz, т.к. tar нужна liblzma.so для xz-декомпрессии)
RUN find /usr/lib /lib -name "liblzma.so*" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libzstd.so*" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libbz2.so*" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libmd.so*" -delete 2>/dev/null; \
    find /usr/lib /lib -name "liblzma.la" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libzstd.la" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libbz2.la" -delete 2>/dev/null; \
    find /usr/lib /lib -name "libmd.la" -delete 2>/dev/null; \
    true

WORKDIR /build/dpkg-${DPKG_VERSION}

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

# Патч 4: libtool стрипает -static из команды линковки.
# Заставляем libtool передавать -static в gcc при статической сборке.
RUN ./configure PERL=/usr/bin/perl \
      LDFLAGS="-static" \
      --prefix=/usr \
      --localstatedir=/var \
      --sysconfdir=/etc \
      --enable-static \
      --disable-shared \
      --disable-dselect \
      --disable-nls \
      --disable-start-stop-daemon \
      --disable-update-alternatives \
      --without-libselinux \
 && perl -0777 -i -pe \
    's{-static \| -static-libtool-libs\)\n\t# The effects of -static are defined in a previous loop\.\n\t# We used to do the same as -all-static on platforms that\n\t# didn.t have a PIC flag, but the assumption that the effects\n\t# would be equivalent was wrong\.  It would break on at least\n\t# Digital Unix and AIX\.\n\tcontinue}{-static | -static-libtool-libs)\n\tfunc_append compile_command " \$link_static_flag"\n\tfunc_append finalize_command " \$link_static_flag"\n\tcontinue}s' \
    libtool \
 && make -j$(nproc)

RUN make DESTDIR=/out install \
 && strip /out/usr/bin/dpkg \
          /out/usr/bin/dpkg-deb \
          /out/usr/bin/dpkg-divert \
          /out/usr/bin/dpkg-query \
          /out/usr/bin/dpkg-realpath \
          /out/usr/bin/dpkg-split \
          /out/usr/bin/dpkg-statoverride \
          /out/usr/bin/dpkg-trigger

# Финальный образ — только результат сборки, без build-essential и исходников.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

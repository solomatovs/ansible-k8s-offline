# Сборка библиотек e2fsprogs (libext2fs, libcom_err, etc.) из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/ext2fs/ext2fs.h
#   /out/usr/lib/libext2fs.{a,so*}
#   /out/usr/lib/libcom_err.{a,so*}
#   /out/usr/lib/libe2p.{a,so*}
#   /out/usr/lib/pkgconfig/ext2fs.pc
# Используется как build-зависимость: libbtrfs (btrfs-progs).

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG E2FSPROGS_VERSION=1.47.0

WORKDIR /build

COPY artifacts/src/e2fsprogs-${E2FSPROGS_VERSION}.tar.gz /build/

RUN tar xzf e2fsprogs-${E2FSPROGS_VERSION}.tar.gz \
 && rm e2fsprogs-${E2FSPROGS_VERSION}.tar.gz

RUN cd e2fsprogs-${E2FSPROGS_VERSION} \
 && ./configure \
      --prefix=/usr \
      --libdir=/usr/lib \
      --enable-elf-shlibs \
      --disable-nls \
      --disable-uuidd \
      --disable-fsck \
      --disable-e2initrd-helper \
 && make -j$(nproc) libs \
 && make DESTDIR=/out install-libs

# Удаляем документацию
RUN rm -rf /out/usr/share \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

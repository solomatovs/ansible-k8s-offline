# Сборка PCRE (Perl Compatible Regular Expressions) из исходников.
# Результат: /out — headers + shared/static libs.
#   /out/usr/include/pcre.h
#   /out/usr/lib/x86_64-linux-gnu/libpcre.{a,so*}
#   /out/usr/lib/x86_64-linux-gnu/pkgconfig/libpcre.pc
# Используется как build-зависимость: libselinux.

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG PCRE_VERSION=8.45


WORKDIR /build

COPY artifacts/src/pcre-${PCRE_VERSION}.tar.bz2 /build/

RUN tar xjf pcre-${PCRE_VERSION}.tar.bz2 \
 && rm pcre-${PCRE_VERSION}.tar.bz2

RUN cd pcre-${PCRE_VERSION} \
 && ./configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --enable-shared \
      --enable-static \
      --enable-utf \
      --enable-unicode-properties \
 && make -j$(nproc) \
 && make DESTDIR=/out install

# Удаляем документацию
RUN rm -rf /out/usr/share /out/usr/bin \
 && find /out -name '*.la' -delete \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}

COPY --from=builder /out /out

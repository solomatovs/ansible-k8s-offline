# Сборка статической и динамической библиотеки libsystemd из исходников systemd (meson).
# Собираем только libsystemd — ninja собирает только библиотечные таргеты,
# демоны и утилиты не компилируются (meson-опции для них не влияют на библиотеку).
#
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libsystemd.a            — статическая библиотека
#   /out/usr/lib/libsystemd.so*          — динамическая библиотека
#   /out/usr/include/systemd/*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/libsystemd.pc — pkg-config
# Использование: COPY --from=libsystemd:241-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### <bison:3.8.2:compilation> ####
#### <libcap:2.25:compilation> ####
#### <libmount:2.30.2:compilation> ####
#### <libgpg-error:1.35:compilation> ####
#### <libgcrypt:1.7.6:compilation> ####
#### <libseccomp:2.5.5:compilation> ####
#### <liblzma:5.2.2:compilation> ####
#### <liblz4:1.9.3:compilation> ####
#### <pcre:8.45:compilation> ####
#### <libselinux:2.6:compilation> ####

#### compilation ####
ARG LIBSYSTEMD_VERSION=241

WORKDIR /build

COPY artifacts/src/systemd-${LIBSYSTEMD_VERSION}.tar.gz /build/

RUN mkdir -p /build/systemd \
 && tar xzf systemd-${LIBSYSTEMD_VERSION}.tar.gz --strip-components=1 -C /build/systemd \
 && rm systemd-${LIBSYSTEMD_VERSION}.tar.gz

WORKDIR /build/systemd

# Патч: shared_library('systemd', ...) в v241 не прокидывает зависимости из libbasic
# (libcap, libmount, libblkid, libselinux, libgcrypt, libseccomp).
# Добавляем недостающие зависимости в shared_library определение.
RUN sed -i "/^libsystemd = shared_library/,/install_dir : rootlibdir)/s/dependencies : \[threads,/dependencies : [threads, libcap, libblkid, libmount, libselinux, libseccomp, libgcrypt,/" meson.build

# Собираем только libsystemd — ninja ниже компилирует только библиотечные таргеты.
# Опции демонов (logind, networkd и т.д.) не влияют на libsystemd и не указываются.
# v241 не имеет опций standalone-binaries и userdb (появились позже).
#
# Библиотеки, встроенные в libsystemd через meson auto-detect (все из цепочки):
#   libcap, libmount, libblkid, libgcrypt + libgpg-error
#   liblzma (xz), liblz4 (сжатие журналов)
#   libseccomp, libselinux + libsepol
RUN meson setup build \
      --prefix=/usr \
      --libdir=/usr/lib \
      -Drootlibdir=/usr/lib \
      -Dstatic-libsystemd=pic \
      -Dtests=false \
      -Dman=false \
      -Dhtml=false \
 && ninja -C build version.h \
 && ninja -C build libsystemd.a \
 && SO_TARGET=$(grep -m1 -oP 'build \K\S*libsystemd\.so\S*(?=\s*:)' build/build.ninja) \
 && { [ -n "$SO_TARGET" ] && ninja -C build "$SO_TARGET" || true; } \
 && mkdir -p /out/usr/lib/pkgconfig /out/usr/include/systemd \
 && find build -type f -name 'libsystemd.a' ! -name 'libsystemd_static.a' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && find build -type f -name 'libsystemd.so.*.*.*' ! -name '*.symbols' | head -1 | xargs -I{} cp {} /out/usr/lib/ \
 && ( cd /out/usr/lib \
   && SO_REAL=$(ls libsystemd.so.*.*.* 2>/dev/null | grep -v '\.symbols$' | head -1) \
   && [ -n "$SO_REAL" ] && ln -sf "$SO_REAL" libsystemd.so.0 && ln -sf libsystemd.so.0 libsystemd.so \
   || true ) \
 && find build -name 'libsystemd.pc' | head -1 | xargs -I{} cp {} /out/usr/lib/pkgconfig/ \
 && cp src/systemd/*.h /out/usr/include/systemd/ \
 && { cp build/src/systemd/*.h /out/usr/include/systemd/ 2>/dev/null || true; } \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

FROM ${BASE_IMAGE}
COPY --from=builder /out /out

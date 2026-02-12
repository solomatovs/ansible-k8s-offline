# Сборка статической и динамической библиотеки libsystemd из исходников systemd (meson).
# Собираем только libsystemd — ninja собирает только библиотечные таргеты,
# демоны и утилиты не компилируются (meson-опции для них не влияют на библиотеку).
# Все C-зависимости подаются как файловые зависимости из artifacts/deps/ (make deps).
#
# Результат: /out (--prefix=/usr)
#   /out/usr/lib/libsystemd.a            — статическая библиотека
#   /out/usr/lib/libsystemd.so*          — динамическая библиотека
#   /out/usr/include/systemd/*.h         — заголовочные файлы
#   /out/usr/lib/pkgconfig/libsystemd.pc — pkg-config
# Использование: COPY --from=libsystemd:241-build /out /

ARG BASE_IMAGE=astra-linux:2.12
ARG TOOLCHAIN_IMAGE=toolchain-gcc:8.5.0-r1-build

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG LIBSYSTEMD_VERSION=241
ARG LIBCAP_VERSION=2.25
ARG LIBMOUNT_VERSION=2.30.2
ARG LIBGPG_ERROR_VERSION=1.35
ARG LIBGCRYPT_VERSION=1.7.6
ARG LIBSECCOMP_VERSION=2.5.5
ARG LIBLZMA_VERSION=5.2.2
ARG LIBLZ4_VERSION=1.9.3
ARG LIBSELINUX_VERSION=2.6

# C-зависимости для сборки (make deps)
COPY artifacts/deps/libcap-${LIBCAP_VERSION}.tar.gz /build/
RUN tar xzf /build/libcap-${LIBCAP_VERSION}.tar.gz -C / \
 && rm /build/libcap-${LIBCAP_VERSION}.tar.gz

COPY artifacts/deps/libmount-${LIBMOUNT_VERSION}.tar.gz /build/
RUN tar xzf /build/libmount-${LIBMOUNT_VERSION}.tar.gz -C / \
 && rm /build/libmount-${LIBMOUNT_VERSION}.tar.gz

COPY artifacts/deps/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.gz /build/
RUN tar xzf /build/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.gz -C / \
 && rm /build/libgpg-error-${LIBGPG_ERROR_VERSION}.tar.gz

COPY artifacts/deps/libgcrypt-${LIBGCRYPT_VERSION}.tar.gz /build/
RUN tar xzf /build/libgcrypt-${LIBGCRYPT_VERSION}.tar.gz -C / \
 && rm /build/libgcrypt-${LIBGCRYPT_VERSION}.tar.gz

COPY artifacts/deps/libseccomp-${LIBSECCOMP_VERSION}.tar.gz /build/
RUN tar xzf /build/libseccomp-${LIBSECCOMP_VERSION}.tar.gz -C / \
 && rm /build/libseccomp-${LIBSECCOMP_VERSION}.tar.gz

COPY artifacts/deps/liblzma-${LIBLZMA_VERSION}.tar.gz /build/
RUN tar xzf /build/liblzma-${LIBLZMA_VERSION}.tar.gz -C / \
 && rm /build/liblzma-${LIBLZMA_VERSION}.tar.gz

COPY artifacts/deps/liblz4-${LIBLZ4_VERSION}.tar.gz /build/
RUN tar xzf /build/liblz4-${LIBLZ4_VERSION}.tar.gz -C / \
 && rm /build/liblz4-${LIBLZ4_VERSION}.tar.gz

COPY artifacts/deps/libselinux-${LIBSELINUX_VERSION}.tar.gz /build/
RUN tar xzf /build/libselinux-${LIBSELINUX_VERSION}.tar.gz -C / \
 && rm /build/libselinux-${LIBSELINUX_VERSION}.tar.gz

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
# Библиотеки, встроенные в libsystemd через meson auto-detect (все из deps/):
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
 && { cp build/src/systemd/*.h /out/usr/include/systemd/ 2>/dev/null || true; }

# Fat package: включаем все build-зависимости (.a, .so, headers, pkgconfig) в /out.
# Это позволяет потребителям (buildah) зависеть только от libsystemd.
RUN for lib in libcap libmount libblkid libuuid libgpg-error libgcrypt \
              libseccomp liblzma liblz4 libselinux libsepol; do \
      cp -a /usr/lib/${lib}.a /out/usr/lib/ 2>/dev/null || true; \
      cp -a /usr/lib/${lib}.so* /out/usr/lib/ 2>/dev/null || true; \
    done \
 && mkdir -p /out/usr/include/sys /out/usr/include/lzma \
 && cp -p /usr/include/sys/capability.h /out/usr/include/sys/ 2>/dev/null || true \
 && cp -rp /usr/include/libmount /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/blkid /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/uuid /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/gpg-error.h /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/gcrypt.h /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/seccomp.h /out/usr/include/ 2>/dev/null || true \
 && cp -p /usr/include/lzma.h /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/lzma/* /out/usr/include/lzma/ 2>/dev/null || true \
 && cp -p /usr/include/lz4.h /usr/include/lz4hc.h /usr/include/lz4frame.h /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/selinux /out/usr/include/ 2>/dev/null || true \
 && cp -rp /usr/include/sepol /out/usr/include/ 2>/dev/null || true \
 && for pc in libcap mount blkid uuid gpg-error libgcrypt libseccomp liblzma liblz4 libselinux libsepol; do \
      cp -p /usr/lib/pkgconfig/${pc}.pc /out/usr/lib/pkgconfig/ 2>/dev/null || true; \
    done

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

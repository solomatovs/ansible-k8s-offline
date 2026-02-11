# Сборка статической и динамической библиотеки libselinux из исходников.
# Также собирает libsepol (зависимость libselinux) из того же проекта SELinux.
# Результат: /out (PREFIX=/usr)
#   /out/usr/lib/libselinux.{a,so*}       — библиотека SELinux
#   /out/usr/lib/libsepol.{a,so*}         — библиотека SELinux policy
#   /out/usr/include/selinux/             — заголовочные файлы
#   /out/usr/include/sepol/              — заголовочные файлы
#   /out/usr/lib/pkgconfig/libselinux.pc — pkg-config
#   /out/usr/lib/pkgconfig/libsepol.pc   — pkg-config
# Использование: COPY --from=libselinux:2.6-build /out /

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

ARG SELINUX_VERSION=2.6
ARG SEPOL_VERSION=2.6
ARG PCRE_VERSION=8.45

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        pkg-config \
        flex \
 && rm -rf /var/lib/apt/lists/*

# --- PCRE (build-зависимость) ---
COPY artifacts/deps/pcre-${PCRE_VERSION}.tar.gz /build/
RUN tar xzf /build/pcre-${PCRE_VERSION}.tar.gz -C / \
 && ldconfig \
 && rm /build/pcre-${PCRE_VERSION}.tar.gz

WORKDIR /build

# GitHub archive для компонентных тегов содержит всё дерево selinux.
# Из libsepol-X.Y.tar.gz берём подкаталог libsepol/
# Из libselinux-X.Y.tar.gz берём подкаталог libselinux/
COPY artifacts/src/libsepol-${SEPOL_VERSION}.tar.gz /build/
COPY artifacts/src/libselinux-${SELINUX_VERSION}.tar.gz /build/

# --- libsepol ---
RUN mkdir -p /build/libsepol \
 && tar xzf libsepol-${SEPOL_VERSION}.tar.gz \
      --wildcards --strip-components=2 \
      -C /build/libsepol \
      "*/libsepol/" \
 && rm libsepol-${SEPOL_VERSION}.tar.gz

# Сборка libsepol
RUN make -C /build/libsepol -j$(nproc) \
      CFLAGS="-O2 -fPIC -Wall -W -Wundef -Wshadow -Wmissing-format-attribute -Wno-error=sign-compare" \
      PREFIX=/usr

# Установка libsepol в систему (для сборки libselinux)
RUN make -C /build/libsepol PREFIX=/usr SHLIBDIR=/usr/lib install

# Установка libsepol в /out (старые Makefile SELinux не поддерживают DESTDIR)
RUN make -C /build/libsepol PREFIX=/out/usr SHLIBDIR=/out/usr/lib install \
 && find /out -name '*.la' -delete

# --- libselinux ---
RUN mkdir -p /build/libselinux \
 && tar xzf libselinux-${SELINUX_VERSION}.tar.gz \
      --wildcards --strip-components=2 \
      -C /build/libselinux \
      "*/libselinux/" \
 && rm libselinux-${SELINUX_VERSION}.tar.gz

# Сборка libselinux
RUN make -C /build/libselinux -j$(nproc) PREFIX=/usr

# Установка libselinux в /out
RUN make -C /build/libselinux PREFIX=/out/usr SHLIBDIR=/out/usr/lib install \
 && find /out -name '*.la' -delete \
 && sed -i 's/Requires.private:.*/Requires.private: libsepol/' /out/usr/lib/pkgconfig/libselinux.pc

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

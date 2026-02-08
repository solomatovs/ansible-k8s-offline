# Сборка buildah из исходников со статической компиляцией.
# Go компилятор берётся из локального образа golang.
# Результат: /out/usr/bin/buildah (статический бинарник)
# Использование: COPY --from=buildah:local /out /

ARG GO_IMAGE=golang-go1.22.6:local
ARG BASE_IMAGE=localhost/astra-linux:2.12

FROM ${GO_IMAGE} AS golang

FROM ${BASE_IMAGE} AS builder

ARG BUILDAH_VERSION=v1.38.0

ENV DEBIAN_FRONTEND=noninteractive

# Go компилятор из локального образа
COPY --from=golang /out/usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /build

COPY artifacts/${BUILDAH_VERSION}.tar.gz /build/
RUN mkdir -p /build/buildah \
 && tar xzf /build/${BUILDAH_VERSION}.tar.gz --strip-components=1 -C /build/buildah \
 && rm /build/${BUILDAH_VERSION}.tar.gz

WORKDIR /build/buildah

# Временные директории для Go-компилятора на обычной ФС (а не tmpfs),
# чтобы не исчерпать место при эмуляции QEMU на arm64-хосте.
ENV GOTMPDIR=/build/tmp
ENV GOCACHE=/build/cache

# Полностью статическая сборка без CGO.
# Build tags:
#   containers_image_openpgp — Go-реализация OpenPGP вместо libgpgme (C)
#   exclude_graphdriver_devicemapper — без device mapper (требует libdevmapper)
#   exclude_graphdriver_btrfs — без btrfs (требует libbtrfs)
RUN mkdir -p /build/tmp /build/cache && \
    CGO_ENABLED=0 \
    go build \
      -mod=vendor \
      -tags "exclude_graphdriver_devicemapper exclude_graphdriver_btrfs containers_image_openpgp" \
      -ldflags '-s -w' \
      -o /out/usr/bin/buildah \
      ./cmd/buildah

# Финальный образ — только результат сборки, без исходников, Go и кэша.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

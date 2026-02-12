# Унифицированный toolchain для Go: наш Go-компилятор + build tools для CGO.
# Используется как базовый образ для:
#   1. Сборки следующих версий Go (golang bootstrap chain)
#   2. Go-проектов, требующих CGO (buildah, etc.) — в будущем
#
# Содержит:
#   - Go компилятор (go, gofmt) — из проекта golang/
#   - C compiler (gcc, libc6-dev) — для CGO
#   - Tools: make, pkg-config, git
#   - ENV: GOROOT, GOPATH, PATH
#
# Использование в проектах:
#   ARG TOOLCHAIN_IMAGE=toolchain-golang:1.24.5-r1-build
#   FROM ${TOOLCHAIN_IMAGE} AS builder
#   ...
#   FROM ${BASE_IMAGE}
#   COPY --from=builder /out /out

ARG BASE_IMAGE=astra-linux:2.12
ARG GOLANG_IMAGE=golang:1.24.5-r1-build

FROM ${GOLANG_IMAGE} AS golang-build

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Build tools для CGO и Go-проектов
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        make \
        pkg-config \
        git \
    && rm -rf /var/lib/apt/lists/*

# Наш Go компилятор
COPY --from=golang-build /out/usr/local/go /usr/local/go

ENV GOROOT=/usr/local/go \
    GOPATH=/go \
    PATH="/usr/local/go/bin:/go/bin:${PATH}"

# Унифицированный toolchain для сборки Go-проектов.
# Содержит:
#   - Go компилятор (из golang:VERSION-build)
#   - gcc, libc6-dev (для CGO)
#   - git, make, pkg-config
#
# Использование в downstream-проектах:
#   ARG TOOLCHAIN_GOLANG_IMAGE
#   FROM ${TOOLCHAIN_GOLANG_IMAGE} AS builder
#   ...

ARG BASE_IMAGE=astra-linux:2.12
ARG GOLANG_IMAGE

FROM ${GOLANG_IMAGE} AS golang-build

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Build-инструменты для CGO и Go-проектов
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        make \
        pkg-config \
        git \
 && rm -rf /var/lib/apt/lists/*

# Go компилятор из golang-проекта
COPY --from=golang-build /out/usr/local/go /usr/local/go

ENV PATH="/usr/local/go/bin:${PATH}"

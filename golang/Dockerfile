# Сборка Go компилятора из исходников с использованием toolchain-golang.
# Каждая версия Go собирается предыдущей версией из цепочки bootstrap.
# TOOLCHAIN_IMAGE (toolchain-golang) уже содержит Go в /usr/local/go и gcc для CGO.
# Результат: /out/usr/local/go/{bin,pkg,src}
# Использование: COPY --from=golang:1.24.5-r1-build /out /

ARG TOOLCHAIN_IMAGE
ARG BASE_IMAGE=astra-linux:2.12

FROM ${TOOLCHAIN_IMAGE} AS builder

ARG GOLANG_VERSION
ARG GO_PROXY_URL=https://proxy.golang.org

WORKDIR /build

COPY artifacts/src/golang-${GOLANG_VERSION}.tar.gz /build/
RUN mkdir -p /build/go \
 && tar xzf /build/golang-${GOLANG_VERSION}.tar.gz --strip-components=1 -C /build/go \
 && rm /build/golang-${GOLANG_VERSION}.tar.gz

WORKDIR /build/go/src

# GOROOT_BOOTSTRAP=/usr/local/go — Go из toolchain-golang
RUN export GOROOT_BOOTSTRAP=/usr/local/go \
 && export GOPROXY=${GO_PROXY_URL} \
 && export CGO_ENABLED=0 \
 && ./make.bash

RUN mkdir -p /out/usr/local/go \
 && cp -a /build/go/bin /build/go/pkg /build/go/src /out/usr/local/go/

# Финальный образ — только результат сборки, без bootstrap и исходников.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out

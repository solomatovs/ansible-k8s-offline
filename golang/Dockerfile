# Сборка Go компилятора из исходников с использованием bootstrap-версии Go.
# Каждая версия Go собирается предыдущей версией из цепочки bootstrap.
# Результат: /out/usr/local/go/{bin,pkg,src}
# Использование: COPY --from=golang-go1.24.5:local /out /

ARG BOOTSTRAP_IMAGE
ARG BASE_IMAGE=localhost/astra-linux:2.12

FROM ${BOOTSTRAP_IMAGE} AS bootstrap

FROM ${BASE_IMAGE}

ARG GO_VERSION
ARG GO_PROXY_URL=https://proxy.golang.org

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=bootstrap /out/usr/local/go /usr/local/go-bootstrap

RUN apt-get update && apt-get install -y \
        build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY artifacts/${GO_VERSION}.tar.gz /build/
RUN mkdir -p /build/go \
 && tar xzf /build/${GO_VERSION}.tar.gz --strip-components=1 -C /build/go \
 && rm /build/${GO_VERSION}.tar.gz

WORKDIR /build/go/src

RUN export GOROOT_BOOTSTRAP=/usr/local/go-bootstrap \
 && export GOPROXY=${GO_PROXY_URL} \
 && export CGO_ENABLED=0 \
 && ./make.bash

RUN mkdir -p /out/usr/local/go \
 && cp -a /build/go/bin /build/go/pkg /build/go/src /out/usr/local/go/

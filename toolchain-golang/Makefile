# =============================================================================
# toolchain-golang — готовый образ для сборки Go-проектов
#
# Содержит: Go компилятор + gcc (для CGO) + git, make, pkg-config
# Используется как FROM-база для проектов на Go (Kubernetes, etcd и т.д.)
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := toolchain-golang
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== go version ===" && \
	go version && \
	echo "=== go env ===" && \
	echo "GOROOT=$$GOROOT" && \
	echo "GOPATH=$$GOPATH" && \
	echo "=== tools ===" && \
	gcc --version | head -1 && \
	git --version && \
	make --version | head -1 && \
	pkg-config --version && \
	echo "" && echo "toolchain-golang $(V): ok"'

include ../mk/project.mk

PF_VERSION    = 1.24.5
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-golang:1.22.6 toolchain-gcc:8.5.0

PF_SRC_URL    = $(GOLANG_SRC_URL)/archive/refs/tags/go$(PF_VERSION).tar.gz
PF_SRC_FILE   = golang-$(PF_VERSION).tar.gz

PF_VERSION    = 1.20.6
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-golang:1.17.13 toolchain-gcc:8.5.0

PF_SRC_URL    = $(GOLANG_SRC_URL)/archive/refs/tags/go$(PF_VERSION).tar.gz
PF_SRC_FILE   = golang-$(PF_VERSION).tar.gz

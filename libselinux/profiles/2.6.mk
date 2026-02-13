PF_VERSION    = 2.6
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 pcre:8.45
SEPOL_VERSION := 2.6

PF_SRC_URL    = $(LIBSELINUX_SRC_URL)/archive/refs/tags/libselinux-$(PF_VERSION).tar.gz
PF_SRC_FILE   = libselinux-$(PF_VERSION).tar.gz

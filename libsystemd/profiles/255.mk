PF_VERSION    = 255
PF_DOCKERFILE = Dockerfile.255
PF_DEPS       = toolchain-gcc:8.5.0 bison:3.8.2 libcap:2.25 libmount:2.30.2 libgpg-error:1.35 libgcrypt:1.7.6 libseccomp:2.5.5 liblzma:5.2.2 liblz4:1.9.3 pcre:8.45 libselinux:2.6

PF_SRC_URL    = $(LIBSYSTEMD_SRC_URL)/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = systemd-$(PF_VERSION).tar.gz

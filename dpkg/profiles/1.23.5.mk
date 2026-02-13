PF_VERSION    = 1.23.5
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 bzip2:1.0.8 libmd:1.1.0 liblzma:5.2.2 zstd:1.5.5

PF_SRC_URL    = $(DEBIAN_MIRROR)/pool/main/d/dpkg/dpkg_$(PF_VERSION).tar.xz
PF_SRC_FILE   = dpkg_$(PF_VERSION).tar.xz

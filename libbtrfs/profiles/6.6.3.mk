PF_VERSION    = 6.6.3
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 zlib:1.3.1 zstd:1.5.5 lzo:2.10 e2fsprogs:1.47.0 bison:3.8.2 libcap:2.25 libmount:2.30.2 libudev:241

PF_SRC_URL    = $(LIBBTRFS_SRC_URL)/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = btrfs-progs-$(PF_VERSION).tar.gz

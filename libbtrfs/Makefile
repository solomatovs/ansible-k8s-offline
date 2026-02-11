-include config.local.mk
-include config.mk

PROJECT     := libbtrfs
BASE_IMAGE  := astra-linux:2.12
VERSION_VAR := BTRFS_VERSION

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/btrfs-progs-$(V).tar.gz

_DEPS = zlib:ZL:ZLIB_VERSION \
        zstd:ZS:ZSTD_VERSION \
        libmount:LM:LIBMOUNT_VERSION \
        lzo:LO:LZO_VERSION \
        e2fsprogs:EF:E2FSPROGS_VERSION \
        libudev:UD:LIBUDEV_VERSION

_TEST_CMD = sh -c '\
	echo "=== files ===" && \
	test -f /out/usr/lib/libbtrfs.a && \
	test -f /out/usr/lib/libbtrfsutil.a && \
	test -f /out/usr/include/btrfs/ioctl.h && \
	ls -lh /out/usr/lib/libbtrfs.a /out/usr/lib/libbtrfsutil.a && \
	echo "=== shared libraries ===" && \
	find /out -name "*.so*" -exec ls -lh {} \; && \
	echo "" && echo "libbtrfs build: ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/btrfs-progs-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GITHUB_URL)/kdave/btrfs-progs/archive/refs/tags/v$*.tar.gz

include ../mk/project.mk

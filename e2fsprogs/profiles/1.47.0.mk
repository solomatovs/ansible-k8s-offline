PF_VERSION    = 1.47.0
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0

PF_SRC_URL    = $(GITHUB_URL)/tytso/e2fsprogs/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = e2fsprogs-$(PF_VERSION).tar.gz

PF_VERSION    = 1.5.5
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0

PF_SRC_URL    = $(GITHUB_URL)/facebook/zstd/releases/download/v$(PF_VERSION)/zstd-$(PF_VERSION).tar.gz
PF_SRC_FILE   = zstd-$(PF_VERSION).tar.gz

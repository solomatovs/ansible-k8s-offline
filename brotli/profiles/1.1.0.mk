PF_VERSION    = 1.1.0
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0

PF_SRC_URL    = $(GITHUB_URL)/google/brotli/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = brotli-$(PF_VERSION).tar.gz

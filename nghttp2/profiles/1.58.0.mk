PF_VERSION    = 1.58.0
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0

PF_SRC_URL    = $(GITHUB_URL)/nghttp2/nghttp2/releases/download/v$(PF_VERSION)/nghttp2-$(PF_VERSION).tar.gz
PF_SRC_FILE   = nghttp2-$(PF_VERSION).tar.gz

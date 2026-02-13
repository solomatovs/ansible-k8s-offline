PF_VERSION    = 1.11.0
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 zlib:1.3.1 openssl:1.1.1w

PF_SRC_URL    = $(GITHUB_URL)/libssh2/libssh2/releases/download/libssh2-$(PF_VERSION)/libssh2-$(PF_VERSION).tar.gz
PF_SRC_FILE   = libssh2-$(PF_VERSION).tar.gz

PF_VERSION    = 2.5.5
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0

PF_SRC_URL    = $(GITHUB_URL)/seccomp/libseccomp/releases/download/v$(PF_VERSION)/libseccomp-$(PF_VERSION).tar.gz
PF_SRC_FILE   = libseccomp-$(PF_VERSION).tar.gz

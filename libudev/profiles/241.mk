PF_VERSION    = 241
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 bison:3.8.2 libcap:2.25 libmount:2.30.2

PF_SRC_URL    = $(GITHUB_URL)/systemd/systemd/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = systemd-$(PF_VERSION).tar.gz

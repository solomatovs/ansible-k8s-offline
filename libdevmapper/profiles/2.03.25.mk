PF_VERSION    = 2.03.25
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0 libaio:0.3.113

PF_SRC_URL    = $(LIBDEVMAPPER_SRC_URL)/archive/refs/tags/v$(subst .,_,$(PF_VERSION)).tar.gz
PF_SRC_FILE   = lvm2-$(PF_VERSION).tar.gz

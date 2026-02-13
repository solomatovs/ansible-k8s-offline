PF_VERSION    = 1.43.0
PF_DEPS       = golang:1.24.5 libdevmapper:2.03.25 libbtrfs:6.6.3 \
                libseccomp:2.5.5 libsystemd:241
PF_DOCKERFILE = Dockerfile.astra

PF_SRC_URL    = $(GITHUB_URL)/containers/buildah/archive/refs/tags/v$(PF_VERSION).tar.gz
PF_SRC_FILE   = buildah-$(PF_VERSION).tar.gz

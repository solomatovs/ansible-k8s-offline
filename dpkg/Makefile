IMAGE        := dpkg-rootless:local
BASE_IMAGE   := localhost/astra-linux:2.12
ARTIFACTS_DIR := artifacts

DPKG_VERSION := 1.23.5
DPKG_URL     := http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_$(DPKG_VERSION).tar.xz

LIBMD_VERSION := 1.1.0
LIBMD_URL     := https://archive.hadrons.org/software/libmd/libmd-$(LIBMD_VERSION).tar.xz

BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg DPKG_VERSION=$(DPKG_VERSION) \
	--build-arg LIBMD_VERSION=$(LIBMD_VERSION)

.PHONY: build download test shell clean

# --- Скачивание исходников (требует интернет) ---
download: $(ARTIFACTS_DIR)/dpkg_$(DPKG_VERSION).tar.xz $(ARTIFACTS_DIR)/libmd-$(LIBMD_VERSION).tar.xz

$(ARTIFACTS_DIR)/dpkg_$(DPKG_VERSION).tar.xz:
	mkdir -p $(ARTIFACTS_DIR)
	curl -fSL -o $@ $(DPKG_URL)

$(ARTIFACTS_DIR)/libmd-$(LIBMD_VERSION).tar.xz:
	mkdir -p $(ARTIFACTS_DIR)
	curl -fSL -o $@ $(LIBMD_URL)

# --- Сборка (работает оффлайн) ---
build: $(ARTIFACTS_DIR)/dpkg_$(DPKG_VERSION).tar.xz $(ARTIFACTS_DIR)/libmd-$(LIBMD_VERSION).tar.xz
	buildah bud $(BUILD_ARGS) -t $(IMAGE) .

test: build
	@ctr=$$(buildah from $(IMAGE)) && \
	buildah run "$$ctr" -- /out/usr/bin/dpkg --version && \
	buildah run "$$ctr" -- sh -c 'ldd /out/usr/bin/dpkg 2>&1 || echo "static: ok"' && \
	buildah rm "$$ctr" > /dev/null

shell: build
	@ctr=$$(buildah from $(IMAGE)) && \
	buildah run --tty "$$ctr" -- /bin/bash; \
	buildah rm "$$ctr" > /dev/null 2>&1 || true

clean:
	@buildah rmi $(IMAGE) 2>/dev/null || true
	@buildah rm --all 2>/dev/null || true

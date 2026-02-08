BASE_IMAGE       := astra-linux:2.12
GO_IMAGE         := golang-go1.22.6:local
BUILDAH_REPO     := https://github.com/containers/buildah.git
BUILDAH_VERSION  := v1.38.0

IMAGE_NAME         := buildah:local
RUNTIME_IMAGE_NAME := buildah-rootless:local
ARTIFACTS_DIR      := artifacts
EXPORT_DIR         := .docker-export

BUILDAH_ARCHIVE_URL = $(BUILDAH_REPO:.git=)/archive/refs/tags

BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GO_IMAGE=$(GO_IMAGE) \
	--build-arg BUILDAH_VERSION=$(BUILDAH_VERSION)

RUNTIME_BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg BUILDAH_IMAGE=$(IMAGE_NAME)

.PHONY: build build-runtime download export \
        ensure ensure-runtime \
        test test-runtime shell clean

# --- Скачивание исходников buildah (требует интернет) ---
download: $(ARTIFACTS_DIR)/$(BUILDAH_VERSION).tar.gz

$(ARTIFACTS_DIR)/%.tar.gz:
	mkdir -p $(ARTIFACTS_DIR)
	curl -fSL -o $@ $(BUILDAH_ARCHIVE_URL)/$*.tar.gz

# ============================================================
# ensure / ensure-runtime : собирает только если образа нет
# build  / build-runtime  : всегда собирает
# ============================================================

ensure: $(ARTIFACTS_DIR)/$(BUILDAH_VERSION).tar.gz
	@buildah inspect $(IMAGE_NAME) > /dev/null 2>&1 \
	  && echo "Image $(IMAGE_NAME) already exists, skipping" \
	  || $(MAKE) build

build: $(ARTIFACTS_DIR)/$(BUILDAH_VERSION).tar.gz
	buildah bud \
	  $(BUILD_ARGS) \
	  -f Dockerfile \
	  -t $(IMAGE_NAME) .

ensure-runtime: ensure
	@buildah inspect $(RUNTIME_IMAGE_NAME) > /dev/null 2>&1 \
	  && echo "Image $(RUNTIME_IMAGE_NAME) already exists, skipping" \
	  || $(MAKE) build-runtime

build-runtime: ensure
	buildah bud \
	  $(RUNTIME_BUILD_ARGS) \
	  -f Dockerfile.runtime \
	  -t $(RUNTIME_IMAGE_NAME) .

test: build
	@ctr=$$(buildah from $(IMAGE_NAME)) && \
	buildah run "$$ctr" -- /out/usr/bin/buildah version && \
	buildah run "$$ctr" -- sh -c 'ldd /out/usr/bin/buildah 2>&1 || echo "static: ok"' && \
	buildah rm "$$ctr" > /dev/null

test-runtime: build-runtime
	@ctr=$$(buildah from $(RUNTIME_IMAGE_NAME)) && \
	buildah run "$$ctr" -- buildah version && \
	buildah rm "$$ctr" > /dev/null

shell: build-runtime
	@ctr=$$(buildah from $(RUNTIME_IMAGE_NAME)) && \
	buildah run --tty "$$ctr" -- /bin/bash; \
	buildah rm "$$ctr" > /dev/null 2>&1 || true

# --- Экспорт образов из buildah в docker-archive (для загрузки в Docker на хосте) ---
export: ensure
	mkdir -p $(EXPORT_DIR)
	buildah push $(BASE_IMAGE) docker-archive:$(EXPORT_DIR)/base-image.tar:$(BASE_IMAGE)
	buildah push $(IMAGE_NAME) docker-archive:$(EXPORT_DIR)/buildah.tar:$(IMAGE_NAME)

clean:
	@buildah rmi $(RUNTIME_IMAGE_NAME) 2>/dev/null || true
	@buildah rmi $(IMAGE_NAME) 2>/dev/null || true
	@rm -rf $(EXPORT_DIR)

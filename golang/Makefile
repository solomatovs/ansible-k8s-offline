BASE_IMAGE    := astra-linux:2.12
GO_REPO       := https://github.com/golang/go.git
GO_PROXY_URL  := https://proxy.golang.org
IMAGE_PREFIX  := golang
ARTIFACTS_DIR := artifacts

# Цепочка bootstrap: go1.4 → go1.17.13 → go1.20.6 → go1.22.6 → go1.24.5
# Каждая версия собирается предыдущей.
LATEST := go1.24.5

GO_VERSIONS := go1.4 go1.17.13 go1.20.6 go1.22.6 go1.24.5

GO_ARCHIVE_URL = $(GO_REPO:.git=)/archive/refs/tags

BUILD_ARGS_COMMON := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GO_PROXY_URL=$(GO_PROXY_URL)

image_name = $(IMAGE_PREFIX)-$(1):local

.PHONY: build build-latest download test shell clean \
        build-go1.4 build-go1.17.13 build-go1.20.6 build-go1.22.6 build-go1.24.5 \
        ensure-go1.4 ensure-go1.17.13 ensure-go1.20.6 ensure-go1.22.6 ensure-go1.24.5

build: ensure-go1.4 ensure-go1.17.13 ensure-go1.20.6 ensure-go1.22.6 ensure-go1.24.5

build-latest: build-$(LATEST)

# --- Скачивание исходников Go (требует интернет) ---
download: $(foreach v,$(GO_VERSIONS),$(ARTIFACTS_DIR)/$(v).tar.gz)

$(ARTIFACTS_DIR)/%.tar.gz:
	mkdir -p $(ARTIFACTS_DIR)
	curl -fSL -o $@ $(GO_ARCHIVE_URL)/$*.tar.gz

# ============================================================
# ensure-* : собирает только если образа нет (используется как зависимость)
# build-*  : всегда собирает (для прямого вызова)
# ============================================================

# --- go1.4 (из C, без bootstrap) ---
ensure-go1.4:
	@buildah inspect $(call image_name,go1.4) > /dev/null 2>&1 \
	  && echo "Image $(call image_name,go1.4) already exists, skipping" \
	  || $(MAKE) build-go1.4

build-go1.4:
	buildah bud \
	  $(BUILD_ARGS_COMMON) \
	  --build-arg GO_VERSION=go1.4 \
	  -f Dockerfile.bootstrap \
	  -t $(call image_name,go1.4) .

# --- go1.17.13 (bootstrap: go1.4) ---
ensure-go1.17.13: ensure-go1.4
	@buildah inspect $(call image_name,go1.17.13) > /dev/null 2>&1 \
	  && echo "Image $(call image_name,go1.17.13) already exists, skipping" \
	  || $(MAKE) build-go1.17.13

build-go1.17.13: ensure-go1.4
	buildah bud \
	  $(BUILD_ARGS_COMMON) \
	  --build-arg BOOTSTRAP_IMAGE=$(call image_name,go1.4) \
	  --build-arg GO_VERSION=go1.17.13 \
	  -f Dockerfile \
	  -t $(call image_name,go1.17.13) .

# --- go1.20.6 (bootstrap: go1.17.13) ---
ensure-go1.20.6: ensure-go1.17.13
	@buildah inspect $(call image_name,go1.20.6) > /dev/null 2>&1 \
	  && echo "Image $(call image_name,go1.20.6) already exists, skipping" \
	  || $(MAKE) build-go1.20.6

build-go1.20.6: ensure-go1.17.13
	buildah bud \
	  $(BUILD_ARGS_COMMON) \
	  --build-arg BOOTSTRAP_IMAGE=$(call image_name,go1.17.13) \
	  --build-arg GO_VERSION=go1.20.6 \
	  -f Dockerfile \
	  -t $(call image_name,go1.20.6) .

# --- go1.22.6 (bootstrap: go1.20.6) ---
ensure-go1.22.6: ensure-go1.20.6
	@buildah inspect $(call image_name,go1.22.6) > /dev/null 2>&1 \
	  && echo "Image $(call image_name,go1.22.6) already exists, skipping" \
	  || $(MAKE) build-go1.22.6

build-go1.22.6: ensure-go1.20.6
	buildah bud \
	  $(BUILD_ARGS_COMMON) \
	  --build-arg BOOTSTRAP_IMAGE=$(call image_name,go1.20.6) \
	  --build-arg GO_VERSION=go1.22.6 \
	  -f Dockerfile \
	  -t $(call image_name,go1.22.6) .

# --- go1.24.5 (bootstrap: go1.22.6) ---
ensure-go1.24.5: ensure-go1.22.6
	@buildah inspect $(call image_name,go1.24.5) > /dev/null 2>&1 \
	  && echo "Image $(call image_name,go1.24.5) already exists, skipping" \
	  || $(MAKE) build-go1.24.5

build-go1.24.5: ensure-go1.22.6
	buildah bud \
	  $(BUILD_ARGS_COMMON) \
	  --build-arg BOOTSTRAP_IMAGE=$(call image_name,go1.22.6) \
	  --build-arg GO_VERSION=go1.24.5 \
	  -f Dockerfile \
	  -t $(call image_name,go1.24.5) .

test: build-$(LATEST)
	@ctr=$$(buildah from $(call image_name,$(LATEST))) && \
	buildah run "$$ctr" -- /out/usr/local/go/bin/go version && \
	buildah rm "$$ctr" > /dev/null

shell: build-$(LATEST)
	@ctr=$$(buildah from $(call image_name,$(LATEST))) && \
	buildah run --tty "$$ctr" -- /bin/bash; \
	buildah rm "$$ctr" > /dev/null 2>&1 || true

clean:
	@buildah rmi $(call image_name,go1.24.5) 2>/dev/null || true
	@buildah rmi $(call image_name,go1.22.6) 2>/dev/null || true
	@buildah rmi $(call image_name,go1.20.6) 2>/dev/null || true
	@buildah rmi $(call image_name,go1.17.13) 2>/dev/null || true
	@buildah rmi $(call image_name,go1.4) 2>/dev/null || true

IMAGE_NAME := buildah-debian:local

.PHONY: build ensure shell clean

# ============================================================
# ensure : собирает только если образа нет (используется как зависимость)
# build  : всегда собирает (для прямого вызова)
# ============================================================

ensure:
	@buildah inspect $(IMAGE_NAME) > /dev/null 2>&1 \
	  && echo "Image $(IMAGE_NAME) already exists, skipping" \
	  || $(MAKE) build

build:
	buildah bud \
	  -f Dockerfile \
	  -t $(IMAGE_NAME) .

shell: build
	@ctr=$$(buildah from $(IMAGE_NAME)) && \
	buildah run --tty "$$ctr" -- /bin/bash; \
	buildah rm "$$ctr" > /dev/null 2>&1 || true

clean:
	@buildah rmi $(IMAGE_NAME) 2>/dev/null || true

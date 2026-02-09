# =============================================================================
# DevOps-образ: rootless buildah + dpkg + golang на Astra Linux
# =============================================================================

# --- Зависимости (должны быть собраны до сборки этого образа) ---
BASE_IMAGE    := astra-linux:2.12
DPKG_IMAGE    := dpkg-astra:1.23.5-build
BUILDAH_IMAGE := buildah-astra:v1.38.0-build
GO_IMAGE      := golang-astra:go1.24.5-build
DEVOPS_IMAGE  := devops-astra:latest

ARTIFACTS_IMAGES := artifacts/images

BUILD_ARGS := \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg DPKG_IMAGE=$(DPKG_IMAGE) \
	--build-arg BUILDAH_IMAGE=$(BUILDAH_IMAGE) \
	--build-arg GO_IMAGE=$(GO_IMAGE)

LABELS := \
	--label org.opencontainers.image.title=devops-astra \
	--label org.opencontainers.image.base.name=$(BASE_IMAGE)

# Собрать зависимость только если образа нет
# $(1) — образ для проверки, $(2) — make-таргет для сборки
ensure_buildah = @buildah inspect $(1) > /dev/null 2>&1 || $(MAKE) $(2)
ensure_docker  = @docker inspect $(1) > /dev/null 2>&1 || $(MAKE) $(2)

.DEFAULT_GOAL := help

.PHONY: help image test shell clean \
        docker-image docker-test docker-shell docker-clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  image            Собрать образ и экспортировать в artifacts/images/"
	@echo "  test             Проверить артефакты сборки: dpkg, buildah, go version"
	@echo "  shell            Запустить shell в контейнере"
	@echo "  clean            Удалить образы, артефакты"
	@echo ""
	@echo "Зависимости (должны быть собраны заранее):"
	@echo "  $(DPKG_IMAGE)"
	@echo "  $(BUILDAH_IMAGE)"
	@echo "  $(GO_IMAGE)"
	@echo ""
	@echo "Примеры:"
	@echo "  make docker/image"
	@echo "  make buildah/test"

# =============================================================================
# Buildah-based (внутри buildah devcontainer)
# =============================================================================

image:
	buildah bud \
	  $(BUILD_ARGS) \
	  $(LABELS) \
	  -t $(DEVOPS_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	rm -f $(ARTIFACTS_IMAGES)/devops-astra.tar
	buildah push $(DEVOPS_IMAGE) docker-archive:$(ARTIFACTS_IMAGES)/devops-astra.tar:$(DEVOPS_IMAGE)

test:
	$(call ensure_buildah,$(DEVOPS_IMAGE),image)
	@ctr=$$(buildah from $(DEVOPS_IMAGE)) && \
	echo "=== dpkg ===" && \
	buildah run "$$ctr" -- /usr/bin/dpkg --version && \
	echo "=== buildah ===" && \
	buildah run "$$ctr" -- /usr/bin/buildah version && \
	echo "=== go ===" && \
	buildah run "$$ctr" -- /usr/local/go/bin/go version && \
	buildah rm "$$ctr" > /dev/null

shell:
	$(call ensure_buildah,$(DEVOPS_IMAGE),image)
	@ctr=$$(buildah from $(DEVOPS_IMAGE)) && \
	buildah run --tty "$$ctr" -- /bin/bash; \
	buildah rm "$$ctr" > /dev/null 2>&1 || true

clean:
	@buildah rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES)

# =============================================================================
# Docker-based (на хосте)
# =============================================================================

docker-image:
	docker build \
	  $(BUILD_ARGS) \
	  $(LABELS) \
	  -t $(DEVOPS_IMAGE) .
	mkdir -p $(ARTIFACTS_IMAGES)
	docker save -o $(ARTIFACTS_IMAGES)/devops-astra.tar $(DEVOPS_IMAGE)

docker-test:
	$(call ensure_docker,$(DEVOPS_IMAGE),docker-image)
	@docker run --rm $(DEVOPS_IMAGE) sh -c '\
	  echo "=== dpkg ===" && /usr/bin/dpkg --version && \
	  echo "=== buildah ===" && /usr/bin/buildah version && \
	  echo "=== go ===" && /usr/local/go/bin/go version'

docker-shell:
	$(call ensure_docker,$(DEVOPS_IMAGE),docker-image)
	@docker run --rm -it $(DEVOPS_IMAGE) /bin/bash

docker-clean:
	@docker rmi $(DEVOPS_IMAGE) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) docker-$*

buildah/%:
	@$(MAKE) $*

ASTRA_VERSION := 2.12
IMAGE_NAME    := astra-linux:$(ASTRA_VERSION)

ARTIFACTS_SRC    := artifacts/src
ARTIFACTS_IMAGES := artifacts/images

# Исходный файл — docker-archive (от docker save)
ARCHIVE     := $(ARTIFACTS_SRC)/astra_linux_ce_$(ASTRA_VERSION)-rootfs
ARCHIVE_TAG := astra_linux_ce_$(ASTRA_VERSION)-rootfs:latest

LABELS := \
	--label org.opencontainers.image.title=astra-linux \
	--label org.opencontainers.image.version=$(ASTRA_VERSION)

# Собрать зависимость только если образа нет
# $(1) — образ для проверки, $(2) — make-таргет для сборки
ensure_buildah = @buildah inspect $(1) > /dev/null 2>&1 || $(MAKE) $(2)
ensure_docker  = @docker inspect $(1) > /dev/null 2>&1 || $(MAKE) $(2)

.DEFAULT_GOAL := help

.PHONY: help image clean docker-image docker-clean

help:
	@echo "Usage: make docker/<target>    (на хосте, через Docker)"
	@echo "       make buildah/<target>   (внутри devcontainer, через Buildah)"
	@echo ""
	@echo "Targets:"
	@echo "  image            Импортировать и экспортировать образ в artifacts/images/"
	@echo "  clean            Удалить образы, артефакты"
	@echo ""
	@echo "Примеры:"
	@echo "  make docker/image"
	@echo "  make buildah/image"

# =============================================================================
# Buildah-based (внутри buildah devcontainer)
# =============================================================================

image:
	buildah pull docker-archive:$(ARCHIVE)
	buildah tag $(ARCHIVE_TAG) $(IMAGE_NAME)
	mkdir -p $(ARTIFACTS_IMAGES)
	rm -f $(ARTIFACTS_IMAGES)/astra-linux-$(ASTRA_VERSION).tar
	buildah push $(IMAGE_NAME) docker-archive:$(ARTIFACTS_IMAGES)/astra-linux-$(ASTRA_VERSION).tar:$(IMAGE_NAME)

clean:
	@buildah rmi $(IMAGE_NAME) 2>/dev/null || true
	@buildah rmi $(ARCHIVE_TAG) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES)

# =============================================================================
# Docker-based (на хосте)
# =============================================================================

docker-image:
	docker load -i $(ARCHIVE)
	docker tag $(ARCHIVE_TAG) $(IMAGE_NAME)
	mkdir -p $(ARTIFACTS_IMAGES)
	docker save -o $(ARTIFACTS_IMAGES)/astra-linux-$(ASTRA_VERSION).tar $(IMAGE_NAME)

docker-clean:
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@docker rmi $(ARCHIVE_TAG) 2>/dev/null || true
	@rm -rf $(ARTIFACTS_IMAGES)

# =============================================================================
# Namespace shortcuts: make docker/<target> или make buildah/<target>
# =============================================================================
docker/%:
	@$(MAKE) docker-$*

buildah/%:
	@$(MAKE) $*

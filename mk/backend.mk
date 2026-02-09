# =============================================================================
# Backend: buildah (по умолчанию) или docker
# Подключение: include ../mk/backend.mk
# =============================================================================
BACKEND ?= buildah

ifeq ($(BACKEND),docker)
  _BUILD   = docker build
  _RMI     = docker rmi
  _INSPECT = docker inspect
  _save    = docker save -o $(2) $(1)
  _run     = docker run --rm $(1) $(2)
  _shell   = docker run --rm -it $(1) /bin/bash
  _extract = id=$$(docker create $(1) true) && docker cp "$$id":/out/. - | gzip > $(2) && docker rm "$$id" > /dev/null
else
  _BUILD   = buildah bud
  _RMI     = buildah rmi
  _INSPECT = buildah inspect
  _save    = rm -f $(2) && buildah push $(1) docker-archive:$(2):$(1)
  _run     = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- $(2) && buildah rm "$$ctr" > /dev/null
  _shell   = ctr=$$(buildah from $(1)) && buildah run --tty "$$ctr" -- /bin/bash; buildah rm "$$ctr" > /dev/null 2>&1 || true
  _extract = ctr=$$(buildah from $(1)) && buildah run "$$ctr" -- tar -cf - -C /out . | gzip > $(2) && buildah rm "$$ctr" > /dev/null
endif

# =============================================================================
# Общий модуль обнаружения и загрузки версий
# Подключение: include ../mk/versions.mk
#
# Предоставляет:
#   VERSIONS        — отсортированный список версий из versions/*.mk
#   V               — текущая выбранная версия
#
# Опционально (задать ДО include):
#   EXTRA_VERSIONS  — дополнительные версии без .mk файлов
# =============================================================================

VERSIONS := $(sort $(basename $(notdir $(wildcard versions/*.mk))))

ifdef EXTRA_VERSIONS
VERSIONS := $(sort $(EXTRA_VERSIONS) $(VERSIONS))
endif

_VERSION_ARGS := $(filter $(VERSIONS),$(MAKECMDGOALS))
V := $(or $(V),$(firstword $(_VERSION_ARGS)))

ifdef V
-include versions/$(V).mk
endif

# Автовыбор Dockerfile: Dockerfile.$(V) если существует, иначе Dockerfile.
# Перезадать: DOCKERFILE=custom или определить _DOCKERFILE после include.
_DOCKERFILE = $(if $(DOCKERFILE),$(DOCKERFILE),$(if $(wildcard Dockerfile.$(V)),Dockerfile.$(V),Dockerfile))

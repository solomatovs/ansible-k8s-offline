# =============================================================================
# Общий модуль обнаружения и загрузки профилей
# Подключение: include ../mk/profiles.mk
#
# Предоставляет:
#   PROFILES        — отсортированный список профилей из profiles/*.mk
#   V               — текущая выбранная версия (профиль)
#
# Опционально (задать ДО include):
#   EXTRA_VERSIONS  — дополнительные версии без .mk файлов
# =============================================================================

PROFILES := $(sort $(basename $(notdir $(wildcard profiles/*.mk))))

ifdef EXTRA_VERSIONS
PROFILES := $(sort $(EXTRA_VERSIONS) $(PROFILES))
endif

# Обратная совместимость: VERSIONS = PROFILES
VERSIONS := $(PROFILES)

_VERSION_ARGS := $(filter $(PROFILES),$(MAKECMDGOALS))
V := $(or $(V),$(firstword $(_VERSION_ARGS)))

ifdef V
-include profiles/$(V).mk
endif


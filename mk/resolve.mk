# =============================================================================
# mk/resolve.mk — Авторазрешение транзитивных версий зависимостей
#
# Загружает version-файлы зависимых проектов, чтобы автоматически
# установить версии транзитивных зависимостей.
#
# Переменная _RESOLVE (задать ДО include):
#   Формат: project:VERSION_VAR [project:VERSION_VAR ...]
#   Порядок важен: родительские зависимости перед дочерними.
#   Пример: _RESOLVE = libsystemd:SYSTEMD_VERSION libgcrypt:GCRYPT_VERSION
#
# Если _RESOLVE не задан, автоматически выводится из _DEPS:
#   _DEPS = zlib:ZL:ZLIB_VERSION  →  _RESOLVE = zlib:ZLIB_VERSION
#
# Приоритет: явные значения из versions/$(V).mk побеждают авторазрешённые.
# Это достигается повторным включением versions/$(V).mk после загрузки
# version-файлов зависимостей.
# =============================================================================

ifndef _RESOLVE
ifdef _DEPS
_RESOLVE = $(foreach dep,$(_DEPS),$(word 1,$(subst :, ,$(dep))):$(word 3,$(subst :, ,$(dep))))
endif
endif

ifdef _RESOLVE
ifdef V
$(foreach r,$(_RESOLVE),$(eval -include ../$(word 1,$(subst :, ,$(r)))/versions/$($(word 2,$(subst :, ,$(r)))).mk))
-include versions/$(V).mk
endif
endif

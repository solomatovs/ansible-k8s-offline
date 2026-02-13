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

# --- Базовые URL (дефолты + export для рекурсии) ---
include ../mk/urls.mk

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

# =============================================================================
# Обработка PF_DEPS
# Формат: project:profile_id [project:profile_id ...]
# Пример: PF_DEPS = zlib:1.3.1 openssl:1.1.1w
# =============================================================================

# Извлечь имя проекта из dep spec
_dep_prj = $(word 1,$(subst :, ,$(1)))
# Извлечь profile ID из dep spec
_dep_pid = $(word 2,$(subst :, ,$(1)))
# Uppercase имя проекта (a-z → A-Z, - → _)
_dep_uc = $(shell echo '$(call _dep_prj,$(1))' | tr 'a-z-' 'A-Z_')

# Генерация --build-arg UC(project)_IMAGE=project:profile-build
define _init_dep
_DEP_BUILD_ARGS += --build-arg $(call _dep_uc,$(1))_IMAGE=$(call _dep_prj,$(1)):$(call _dep_pid,$(1))-build
endef

ifdef PF_DEPS
$(foreach dep,$(PF_DEPS),$(eval $(call _init_dep,$(dep))))
endif

# =============================================================================
# Рекурсивная проверка наличия исходников в указанной директории
# Usage: $(MAKE) _check_src V=<version> DEST=<abs_path>
#
# Логика:
#   1. Если PF_SRC_FILE определён — проверяет что файл есть в DEST
#   2. Для каждого dep в PF_DEPS — рекурсивно проверяет в проекте зависимости
#   3. При отсутствии файла — выдаёт ошибку с рекомендацией запустить make download
# =============================================================================
.PHONY: _check_src
_check_src:
ifdef PF_SRC_FILE
	@test -f $(DEST)/$(PF_SRC_FILE) || \
	  { echo "Ошибка: $(DEST)/$(PF_SRC_FILE) не найден."; \
	    echo "  Выполните: make download $(V)"; exit 1; }
endif
	@$(foreach dep,$(PF_DEPS),\
	  $(MAKE) -C ../$(call _dep_prj,$(dep)) --no-print-directory \
	    _check_src V=$(call _dep_pid,$(dep)) DEST=$(DEST);)

# =============================================================================
# Рекурсивный вывод URL-ов исходников
# Usage: $(MAKE) _list_urls V=<version> DEST=<rel_path>
#
# Логика:
#   1. Если PF_SRC_URL определён — выводит строку: URL DEST FILENAME
#   2. Для каждого dep в PF_DEPS — рекурсивно вызывает _list_urls
#   3. DEST — относительный путь от корня репозитория (напр. curl/artifacts/src)
#   4. Вывод на stdout — можно использовать для оркестрации
# =============================================================================
.PHONY: _list_urls
_list_urls:
ifdef PF_SRC_URL
	@echo "$(PF_SRC_URL) $(DEST) $(PF_SRC_FILE)"
endif
	@$(foreach dep,$(PF_DEPS),\
	  $(MAKE) -C ../$(call _dep_prj,$(dep)) --no-print-directory \
	    _list_urls V=$(call _dep_pid,$(dep)) DEST=$(DEST);)

# =============================================================================
# Рекурсивная загрузка исходников в указанную директорию
# Usage: $(MAKE) _download_to V=<version> DEST=<abs_path>
#
# Логика:
#   1. Если PF_SRC_URL определён — скачивает файл в DEST (пропускает если уже есть)
#   2. Для каждого dep в PF_DEPS — рекурсивно вызывает _download_to в проекте зависимости
#   3. DEST остаётся одним и тем же на всю глубину рекурсии
# =============================================================================
.PHONY: _download_to
_download_to:
ifdef PF_SRC_URL
	@mkdir -p $(DEST)
	@test -f $(DEST)/$(PF_SRC_FILE) || \
	  { echo "  Скачиваю $(PF_SRC_FILE)..."; \
	    curl -fSL -o $(DEST)/$(PF_SRC_FILE) "$(PF_SRC_URL)"; }
endif
	@$(foreach dep,$(PF_DEPS),\
	  $(MAKE) -C ../$(call _dep_prj,$(dep)) --no-print-directory \
	    _download_to V=$(call _dep_pid,$(dep)) DEST=$(DEST);)


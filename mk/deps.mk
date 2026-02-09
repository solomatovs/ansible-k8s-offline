# =============================================================================
# Макросы для работы с зависимостями
# Подключение: include ../mk/deps.mk
# =============================================================================

# Универсальная проверка наличия dep-файла
# Использование: $(call check_dep,/path/to/dep.tar.gz)
check_dep = @test -f $(1) || (echo "Ошибка: $(1) не найден"; echo "Выполните: make deps $(V)"; exit 1)

# Генерация правила извлечения зависимости из Docker-образа
# Использование: $(eval $(call dep_rule,image_prefix,project_dir))
# Пример:       $(eval $(call dep_rule,libcap,libcap))
# Создаёт правило: $(ARTIFACTS_DEPS)/libcap-%.tar.gz
define dep_rule
$$(ARTIFACTS_DEPS)/$(1)-%.tar.gz:
	@$$(_INSPECT) $(1):$$*-build > /dev/null 2>&1 || \
	  (echo "Ошибка: образ $(1):$$*-build не найден"; \
	   echo "Сначала соберите: make -C ../$(2) docker/image $$*"; exit 1)
	mkdir -p $$(ARTIFACTS_DEPS)
	@$$(call _extract,$(1):$$*-build,$$@)
endef

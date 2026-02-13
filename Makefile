# =============================================================================
# Makefile — Точка входа
# =============================================================================
#
# Каждый проект описывает зависимости в profiles/*.mk (_REQUIRES).
# Резолвер mk/resolve-order.sh вычисляет порядок сборки.
#
# Прямая сборка отдельного проекта:
#   make -C zlib docker/build 1.3.1
#   make -C openssl docker/download 1.1.1w && make -C openssl docker/build 1.1.1w
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help

help:
	@echo "═══════════════════════════════════════════════════"
	@echo " Сборка проектов"
	@echo "═══════════════════════════════════════════════════"
	@echo ""
	@echo "Резолвер зависимостей (порядок сборки):"
	@echo "  ./mk/resolve-order.sh openssl:1.1.1w"
	@echo "  ./mk/resolve-order.sh buildah:1.38.0"
	@echo "  ./mk/resolve-order.sh devops:full"
	@echo ""
	@echo "Прямая сборка проекта:"
	@echo "  make -C zlib docker/build 1.3.1"
	@echo "  make -C openssl docker/download 1.1.1w"
	@echo "  make -C openssl docker/build 1.1.1w"

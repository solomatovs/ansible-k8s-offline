# =============================================================================
# gcc — GCC компилятор (единые профили)
#
# Профили компилятора: 8.5.0, 9.5.0, 10.5.0, 11.4.0, 12.3.0, 13.2.0, 14.2.0
# Профили toolchain:   toolchain-8.5.0, ..., toolchain-14.2.0
#
# Bootstrap-цепочка: 8.5.0 (system) -> 9.5.0 -> 10.5.0 -> 11.4.0 -> 12.3.0 -> 13.2.0 -> 14.2.0
# Toolchain = GCC компилятор + autotools + cmake + meson + unified CFLAGS
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := gcc
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gcc && \
	test -f /out/usr/bin/g++ && \
	echo "gcc $(V): ok"'

_HELP_EXTRA = echo "  Bootstrap-цепочка: 8.5.0 -> 9.5.0 -> 10.5.0 -> 11.4.0 -> 12.3.0 -> 13.2.0 -> 14.2.0"; \
              echo "  Toolchain-профили: toolchain-8.5.0, toolchain-9.5.0, ..., toolchain-14.2.0"

# Chain-рендерер: собирает всю bootstrap-цепочку в один multi-stage Dockerfile
# Все версии и зависимости разрешаются рендерером — передаём только BASE_IMAGE
_RENDER = ../mk/render-chain.sh $(PROJECT) $(V)
_BUILD_ARGS = --build-arg BASE_IMAGE=$(BASE_IMAGE)

include ../mk/project.mk

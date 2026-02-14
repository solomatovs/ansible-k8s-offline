# =============================================================================
# golang — Go компилятор + toolchain (единые профили)
#
# Профили компилятора: 1.4, 1.17.13, 1.20.6, 1.22.6, 1.24.5
# Профили toolchain:   toolchain-1.4, toolchain-1.17.13, ..., toolchain-1.24.5
#
# Bootstrap-цепочка: 1.4 (C) -> 1.17.13 -> 1.20.6 -> 1.22.6 -> 1.24.5
# Toolchain = Go компилятор + gcc + git + make + pkg-config
# =============================================================================

-include config.local.mk
-include config.mk

PROJECT    := golang
BASE_IMAGE := astra-linux:2.12

_TEST_CMD = sh -c '\
	echo "=== go version ===" && \
	GOROOT=/out/usr/local/go /out/usr/local/go/bin/go version && \
	echo "=== structure ===" && \
	ls -ld /out/usr/local/go/bin /out/usr/local/go/pkg /out/usr/local/go/src && \
	echo "" && echo "golang $(V): ok"'

_HELP_EXTRA = echo "  Bootstrap-цепочка: 1.4 -> 1.17.13 -> 1.20.6 -> 1.22.6 -> 1.24.5"; \
              echo "  Toolchain-профили: toolchain-1.4, toolchain-1.17.13, ..., toolchain-1.24.5"

include ../mk/project.mk

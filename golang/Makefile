# =============================================================================
# golang — сборка Go из исходников (рекурсивный bootstrap)
#
# Цепочка: 1.4 (C) -> 1.17.13 -> 1.20.6 -> 1.22.6 -> 1.24.5
# Go 1.4 — последняя версия на C, все последующие компилируются предыдущей.
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

_HELP_EXTRA = echo "  Цепочка bootstrap: 1.4 -> 1.17.13 -> 1.20.6 -> 1.22.6 -> 1.24.5"

include ../mk/project.mk

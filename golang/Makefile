-include config.local.mk
-include config.mk

GO_PROXY_URL ?= $(GOPROXY_URL)
PROJECT      := golang
BASE_IMAGE   := astra-linux:2.12

# --- Дополнительные build-args ---
_EXTRA_BUILD_ARGS = --build-arg GO_PROXY_URL=$(GO_PROXY_URL)

# --- Тестирование (по умолчанию build, профили переопределяют через PF_TEST_CMD) ---
_TEST_CMD = $(or $(PF_TEST_CMD),/out/usr/local/go/bin/go version)

# --- Help: дополнительные строки ---
_HELP_EXTRA = echo "  Цепочка bootstrap: 1.4 -> 1.17.13 -> 1.20.6 -> 1.22.6 -> 1.24.5"

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := glibc
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/glibc-$(PF_VERSION).tar.xz

_EXTRA_SRC_FILES = $(if $(KERNEL_VERSION),$(ARTIFACTS_SRC)/linux-$(KERNEL_VERSION).tar.xz)
_EXTRA_BUILD_ARGS = $(if $(KERNEL_VERSION),--build-arg KERNEL_VERSION=$(KERNEL_VERSION))

_TEST_CMD = sh -c '\
	test -f /out/lib/x86_64-linux-gnu/libc-$(PF_VERSION).so && \
	test -f /out/lib/x86_64-linux-gnu/ld-$(PF_VERSION).so && \
	echo "glibc $(PF_VERSION): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/glibc-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/glibc/glibc-$*.tar.xz

# --- Скачивание исходников ядра (для kernel headers) ---
$(ARTIFACTS_SRC)/linux-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(KERNEL_URL)/v$(word 1,$(subst ., ,$*)).x/linux-$*.tar.xz

include ../mk/project.mk

-include config.local.mk
-include config.mk

PROJECT    := gcc
BASE_IMAGE := astra-linux:2.12

ARTIFACTS_SRC := artifacts/src

SRC_FILE = $(ARTIFACTS_SRC)/gcc-$(V).tar.xz

# GMP, MPFR, MPC собираются in-tree (внутри дерева исходников GCC)
_EXTRA_SRC_FILES = \
    $(if $(GMP_VERSION),$(ARTIFACTS_SRC)/gmp-$(GMP_VERSION).tar.xz) \
    $(if $(MPFR_VERSION),$(ARTIFACTS_SRC)/mpfr-$(MPFR_VERSION).tar.xz) \
    $(if $(MPC_VERSION),$(ARTIFACTS_SRC)/mpc-$(MPC_VERSION).tar.gz)

_EXTRA_BUILD_ARGS = \
    $(if $(GMP_VERSION),--build-arg GMP_VERSION=$(GMP_VERSION)) \
    $(if $(MPFR_VERSION),--build-arg MPFR_VERSION=$(MPFR_VERSION)) \
    $(if $(MPC_VERSION),--build-arg MPC_VERSION=$(MPC_VERSION))

_TEST_CMD = sh -c '\
	test -f /out/usr/bin/gcc && \
	test -f /out/usr/bin/g++ && \
	echo "gcc $(V): ok"'

# --- Скачивание исходников ---
$(ARTIFACTS_SRC)/gcc-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/gcc/gcc-$*/gcc-$*.tar.xz

$(ARTIFACTS_SRC)/gmp-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/gmp/gmp-$*.tar.xz

$(ARTIFACTS_SRC)/mpfr-%.tar.xz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/mpfr/mpfr-$*.tar.xz

$(ARTIFACTS_SRC)/mpc-%.tar.gz:
	mkdir -p $(ARTIFACTS_SRC)
	curl -fSL -o $@ $(GNU_URL)/mpc/mpc-$*.tar.gz

include ../mk/project.mk

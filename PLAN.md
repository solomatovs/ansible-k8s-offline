# План: Локализация ARTIFACTS_SRC — каждый проект скачивает ВСЁ к себе

## Проблема

Сейчас render-dockerfile.sh при включении регионов (#### <project:profile:region> ####) подставляет в COPY
путь **исходного** проекта:

```
# curl/Dockerfile включает #### <zlib:1.3.1:compilation> ####
# → rendered: COPY zlib/artifacts/src/zlib-1.3.1.tar.gz /build/
```

Это значит build curl'а читает файлы из `zlib/artifacts/src/`, `gcc/artifacts/src/` и т.д. — нарушается принцип
"build берёт исходники только из своей директории".

## Целевая архитектура

- **download** — скачивает ВСЁ (своё + все зависимости транзитивно) в свой `artifacts/src/`
- **build** — Dockerfile COPY только из `<project>/artifacts/src/` (текущий проект)
- **export** — пишет только в свой `artifacts/build/`

## Изменения

### Шаг 1: render-dockerfile.sh — COPY всегда с текущим проектом

В функции `extract_region()` (строка 75) изменить `${project}` → `${PROJECT}`:

```bash
# Было:
echo "COPY ${project}/${line#COPY }"
# Стало:
echo "COPY ${PROJECT}/${line#COPY }"
```

Теперь все COPY (включая из регионов других проектов) указывают на каталог ТЕКУЩЕГО проекта.

### Шаг 2: Добавить PF_SRC_URL и PF_SRC_FILE в профили

Каждый профиль, у которого есть скачиваемые исходники, получает два новых поля:

```makefile
# zlib/profiles/1.3.1.mk
PF_VERSION    = 1.3.1
PF_DOCKERFILE = Dockerfile
PF_DEPS       = toolchain-gcc:8.5.0
PF_SRC_URL    = https://zlib.net/fossils/zlib-$(PF_VERSION).tar.gz
PF_SRC_FILE   = zlib-$(PF_VERSION).tar.gz
```

Профили без собственных исходников (toolchain-gcc, toolchain-golang, devops) — **без** PF_SRC_URL/PF_SRC_FILE.

**Полный список профилей с PF_SRC_URL** (40 проектов × N версий):

| Проект | PF_SRC_URL шаблон | PF_SRC_FILE шаблон |
|--------|---|---|
| zlib | `https://zlib.net/fossils/zlib-$(PF_VERSION).tar.gz` | `zlib-$(PF_VERSION).tar.gz` |
| bison | `https://ftp.gnu.org/gnu/bison/bison-$(PF_VERSION).tar.xz` | `bison-$(PF_VERSION).tar.xz` |
| brotli | `https://github.com/google/brotli/archive/refs/tags/v$(PF_VERSION).tar.gz` | `brotli-$(PF_VERSION).tar.gz` |
| bzip2 | `https://sourceware.org/pub/bzip2/bzip2-$(PF_VERSION).tar.gz` | `bzip2-$(PF_VERSION).tar.gz` |
| curl | (URL из Makefile) | `curl-$(PF_VERSION).tar.gz` |
| dpkg | `http://deb.debian.org/debian/pool/main/d/dpkg/dpkg_$(PF_VERSION).tar.xz` | `dpkg_$(PF_VERSION).tar.xz` |
| e2fsprogs | `https://github.com/tytso/e2fsprogs/archive/refs/tags/v$(PF_VERSION).tar.gz` | `e2fsprogs-$(PF_VERSION).tar.gz` |
| gawk | `https://ftp.gnu.org/gnu/gawk/gawk-$(PF_VERSION).tar.xz` | `gawk-$(PF_VERSION).tar.xz` |
| gcc | `https://ftp.gnu.org/gnu/gcc/gcc-$(PF_VERSION)/gcc-$(PF_VERSION).tar.xz` | `gcc-$(PF_VERSION).tar.xz` |
| git | `https://github.com/git/git/archive/refs/tags/v$(PF_VERSION).tar.gz` | `git-$(PF_VERSION).tar.gz` |
| glibc | `https://ftp.gnu.org/gnu/glibc/glibc-$(PF_VERSION).tar.xz` | `glibc-$(PF_VERSION).tar.xz` |
| golang | `https://github.com/golang/go/archive/refs/tags/go$(PF_VERSION).tar.gz` | `golang-$(PF_VERSION).tar.gz` |
| kerberos | `https://kerberos.org/dist/krb5/1.20/krb5-$(PF_VERSION).tar.gz` (major.minor хардкод) | `krb5-$(PF_VERSION).tar.gz` |
| libaio | (URL из Makefile) | `libaio-$(PF_VERSION).tar.gz` |
| libbtrfs | `https://github.com/kdave/btrfs-progs/archive/refs/tags/v$(PF_VERSION).tar.gz` | `btrfs-progs-$(PF_VERSION).tar.gz` |
| libcap | (URL из Makefile) | `libcap-$(PF_VERSION).tar.xz` |
| libdevmapper | `https://github.com/lvmteam/lvm2/archive/refs/tags/v$(subst .,_,$(PF_VERSION)).tar.gz` | `lvm2-$(PF_VERSION).tar.gz` |
| libgcrypt | (URL из Makefile) | `libgcrypt-$(PF_VERSION).tar.bz2` |
| libgpg-error | (URL из Makefile) | `libgpg-error-$(PF_VERSION).tar.bz2` |
| libidn2 | `https://ftp.gnu.org/gnu/libidn/libidn2-$(PF_VERSION).tar.gz` | `libidn2-$(PF_VERSION).tar.gz` |
| liblz4 | `https://github.com/lz4/lz4/archive/refs/tags/v$(PF_VERSION).tar.gz` | `lz4-$(PF_VERSION).tar.gz` |
| liblzma | (URL из Makefile) | `xz-$(PF_VERSION).tar.gz` |
| libmd | (URL из Makefile) | `libmd-$(PF_VERSION).tar.xz` |
| libmount | `https://github.com/util-linux/util-linux/archive/refs/tags/v$(PF_VERSION).tar.gz` | `util-linux-$(PF_VERSION).tar.gz` |
| libseccomp | `https://github.com/seccomp/libseccomp/releases/download/v$(PF_VERSION)/libseccomp-$(PF_VERSION).tar.gz` | `libseccomp-$(PF_VERSION).tar.gz` |
| libselinux | `https://github.com/SELinuxProject/selinux/archive/refs/tags/libselinux-$(PF_VERSION).tar.gz` | `libselinux-$(PF_VERSION).tar.gz` |
| libssh2 | `https://github.com/libssh2/libssh2/releases/download/libssh2-$(PF_VERSION)/libssh2-$(PF_VERSION).tar.gz` | `libssh2-$(PF_VERSION).tar.gz` |
| libstdcxx | `https://ftp.gnu.org/gnu/gcc/gcc-$(PF_VERSION)/gcc-$(PF_VERSION).tar.xz` | `gcc-$(PF_VERSION).tar.xz` |
| libsystemd | `https://github.com/systemd/systemd/archive/refs/tags/v$(PF_VERSION).tar.gz` | `systemd-$(PF_VERSION).tar.gz` |
| libudev | `https://github.com/systemd/systemd/archive/refs/tags/v$(PF_VERSION).tar.gz` | `systemd-$(PF_VERSION).tar.gz` |
| libunistring | `https://ftp.gnu.org/gnu/libunistring/libunistring-$(PF_VERSION).tar.gz` | `libunistring-$(PF_VERSION).tar.gz` |
| lzo | (URL из Makefile) | `lzo-$(PF_VERSION).tar.gz` |
| nghttp2 | `https://github.com/nghttp2/nghttp2/releases/download/v$(PF_VERSION)/nghttp2-$(PF_VERSION).tar.gz` | `nghttp2-$(PF_VERSION).tar.gz` |
| nghttp3 | `https://github.com/ngtcp2/nghttp3/releases/download/v$(PF_VERSION)/nghttp3-$(PF_VERSION).tar.gz` | `nghttp3-$(PF_VERSION).tar.gz` |
| ngtcp2 | `https://github.com/ngtcp2/ngtcp2/releases/download/v$(PF_VERSION)/ngtcp2-$(PF_VERSION).tar.gz` | `ngtcp2-$(PF_VERSION).tar.gz` |
| openldap | (URL из Makefile) | `openldap-$(PF_VERSION).tgz` |
| openssl | `https://www.openssl.org/source/openssl-$(PF_VERSION).tar.gz` | `openssl-$(PF_VERSION).tar.gz` |
| pcre | (URL из Makefile) | `pcre-$(PF_VERSION).tar.bz2` |
| zstd | `https://github.com/facebook/zstd/releases/download/v$(PF_VERSION)/zstd-$(PF_VERSION).tar.gz` | `zstd-$(PF_VERSION).tar.gz` |
| buildah | `https://github.com/containers/buildah/archive/refs/tags/v$(PF_VERSION).tar.gz` | `buildah-$(PF_VERSION).tar.gz` |

### Шаг 3: Добавить `_download_to` в mk/profiles.mk

Новый target в конце profiles.mk — рекурсивно скачивает исходники в DEST:

```makefile
# --- Рекурсивная загрузка исходников в указанную директорию ---
# Usage: $(MAKE) _download_to V=<version> DEST=<abs_path>
_download_to:
ifdef PF_SRC_URL
	@mkdir -p $(DEST)
	@test -f $(DEST)/$(PF_SRC_FILE) || \
	  { echo "  Скачиваю $(PF_SRC_FILE)..."; \
	    curl -fSL -o $(DEST)/$(PF_SRC_FILE) "$(PF_SRC_URL)"; }
endif
	@$(foreach dep,$(PF_DEPS),\
	  $(MAKE) -C ../$(call _dep_prj,$(dep)) _download_to \
	    V=$(call _dep_pid,$(dep)) DEST=$(DEST);)
```

Логика:
1. Если PF_SRC_URL определён — скачивает файл в DEST (пропускает если уже есть)
2. Для каждого dep в PF_DEPS — рекурсивно вызывает _download_to в проекте зависимости
3. DEST остаётся **одним и тем же** на всю глубину рекурсии → все файлы попадают в один каталог

### Шаг 4: Упростить download в mk/project.mk

Заменить:
```makefile
download:
	$(call check_version)
	@$(MAKE) $(_SRC_FILES)
	@$(foreach dep,$(PF_DEPS),\
	  $(MAKE) -C ../$(call _dep_prj,$(dep)) download V=$(call _dep_pid,$(dep));)
```

На:
```makefile
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
```

Также обновить SRC_FILE — вывести из PF_SRC_FILE:
```makefile
# Если PF_SRC_FILE задан в профиле, SRC_FILE выводится автоматически
ifdef PF_SRC_FILE
SRC_FILE ?= $(ARTIFACTS_SRC)/$(PF_SRC_FILE)
endif
```

### Шаг 5: Упростить download в кастомных Makefiles

Для buildah, golang, dpkg, devops, toolchain-gcc, toolchain-golang — заменить текущие download targets на:
```makefile
download:
	$(call check_version)
	@$(MAKE) _download_to V=$(V) DEST=$(CURDIR)/$(ARTIFACTS_SRC)
```

### Шаг 6: Удалить устаревшие URL-переменные и pattern rules

Из каждого Makefile удалить:
- Переменные URL (GITHUB_URL, GNU_URL, ZLIB_URL, и т.д.)
- Pattern rules для скачивания (`$(ARTIFACTS_SRC)/zlib-%.tar.gz:`)
- Определение ARTIFACTS_SRC (уже в backend.mk)
- Определение SRC_FILE (если PF_SRC_FILE покрывает его)

### Шаг 7: Тестирование

1. `make docker/help` для всех проектов (43/43)
2. `make docker/render <ver>` — проверить что COPY пути указывают на текущий проект
3. `make docker/download <ver>` — проверить что все файлы в локальном artifacts/src/
4. `make docker/build <ver>` — полная сборка
5. `make docker/export <ver>` — экспорт артефактов

## Порядок реализации

1. render-dockerfile.sh (1 строка) → сразу всё ломает build (COPY пути изменились)
2. profiles.mk + _download_to
3. Профили (PF_SRC_URL/PF_SRC_FILE) — массово по всем проектам
4. project.mk download
5. Кастомные Makefiles download
6. Cleanup: убрать URL-переменные и pattern rules
7. Тестирование

## Важные замечания

- **glibc**: имеет _EXTRA_SRC_FILES (ядро Linux). Нужно PF_SRC_URL_2/PF_SRC_FILE_2 или ручная обработка.
- **libselinux**: имеет _EXTRA_SRC_FILES (libsepol). Аналогично.
- **libstdcxx и libudev**: делят исходники с gcc и libsystemd соответственно — одинаковый PF_SRC_FILE.
- **kerberos**: major.minor в URL пути — можно хардкодить в профиле (каждый профиль для конкретной версии).
- **libdevmapper**: `$(subst .,_,$(PF_VERSION))` в URL — Make вычислит при раскрытии.

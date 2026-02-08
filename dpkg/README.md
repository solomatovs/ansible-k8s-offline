# dpkg-rootless (static)

Сборка dpkg 1.23.5 с патчами для rootless-установки .deb пакетов.
Бинарники полностью статические — переносимы между любыми Linux x86_64.

## Сборка

```bash
cd dpkg
make build     # собрать образ
make test      # проверить версию и статичность
make shell     # войти в контейнер с образом
make clean     # удалить образ
```

## Использование в других Dockerfile

```dockerfile
FROM localhost/dpkg-rootless:local AS dpkg
FROM localhost/astra-linux:2.12

COPY --from=dpkg /out /
RUN dpkg --version
```

## Хранение образов

Образы хранятся в именованном Docker volume `buildah-storage` (монтируется
в `/var/lib/containers`). Volume переживает пересоздание devcontainer.

## Патчи

1. **Rootless UID bypass** — `dbmodify.c`: убрана проверка `getuid()`
2. **Rootless uid/gid override** — `archives.c`: подмена root:root на текущего пользователя
3. **Perl 5.24 compat** — `configure`: хардкод архитектуры amd64 (скрипт требует Perl 5.36)
4. **Libtool static fix** — `libtool`: принудительная передача `-static` в gcc

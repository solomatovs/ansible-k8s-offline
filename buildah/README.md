# buildah (static build from source)

Сборка buildah из исходников со статической компиляцией.
Go компилятор берётся из локального образа `golang-go1.24.5:local`.

## Сборка

```bash
cd buildah
make download          # скачать исходники (требует интернет)
make build             # собрать статический бинарник
make ensure            # собрать только если образа ещё нет
make test              # проверить: buildah version + статическая линковка
make shell             # войти в контейнер
make clean             # удалить образ
```

## Параметры

```bash
# Указать другую версию buildah:
make build BUILDAH_VERSION=v1.37.5

# Указать другой образ Go компилятора:
make build GO_IMAGE=golang-go1.22.6:local

# Сменить базовый образ:
make build BASE_IMAGE=localhost/debian:bullseye
```

## Использование в других Dockerfile

```dockerfile
FROM buildah:local AS buildah
FROM localhost/astra-linux:2.12

COPY --from=buildah /out/usr/bin/buildah /usr/bin/buildah
RUN buildah version
```

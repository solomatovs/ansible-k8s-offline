# golang (bootstrap chain)

Сборка Go компилятора из исходников через цепочку bootstrap:

```
go1.4 (из C) → go1.17.13 → go1.20.6 → go1.22.6 → go1.24.5
```

Каждая версия собирается предыдущей. go1.4 компилируется из C без Go.

## Сборка

```bash
cd golang
make build            # собрать всю цепочку
make build-go1.4      # собрать только go1.4
make build-go1.24.5   # собрать до go1.24.5 (включая зависимости)
make build-latest     # алиас для последней версии
make test             # проверить: go version
make shell            # войти в контейнер с последним Go
make clean            # удалить все образы
```

## Параметры

```bash
# Использовать приватный репозиторий:
make build GO_REPO=https://my-gitlab.local/mirrors/go.git

# Указать прокси для модулей:
make build GO_PROXY_URL=https://my-proxy.local

# Сменить базовый образ:
make build BASE_IMAGE=localhost/debian:bullseye
```

## Использование в других Dockerfile

```dockerfile
FROM localhost/golang-go1.24.5:local AS golang
FROM localhost/astra-linux:2.12

COPY --from=golang /out/usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"
RUN go version
```

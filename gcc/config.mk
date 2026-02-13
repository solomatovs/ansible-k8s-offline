# config.mk — настройки по умолчанию
# Переопределить: создать config.local.mk или задать переменные окружения.
# Подробнее: см. config.local.mk.example

# Build tools (собираются отдельными проектами, используются через COPY --from)
GMP_VERSION  ?= 6.2.1
MPFR_VERSION ?= 4.2.1
MPC_VERSION  ?= 1.3.1

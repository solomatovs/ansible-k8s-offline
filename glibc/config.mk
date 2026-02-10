# config.mk — настройки по умолчанию
# Переопределить: создать config.local.mk или задать переменные окружения.
# Подробнее: см. config.local.mk.example

GNU_URL    ?= https://ftp.gnu.org/gnu
KERNEL_URL ?= https://cdn.kernel.org/pub/linux/kernel

# Build tools (собираются отдельными проектами, используются через COPY --from)
BISON_VERSION ?= 3.8.2
GAWK_VERSION  ?= 5.2.2

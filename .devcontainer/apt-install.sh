#!/bin/sh
set -e

# Проверяем, переданы ли аргументы
if [ $# -eq 0 ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

PACKAGE_NAME=$1

echo "--- Phase 1: Downloading and unpacking $PACKAGE_NAME ---"
# Скачиваем и распаковываем, но не настраиваем (пропускаем ошибки настройки)
apt-get update
apt-get install -y --no-install-recommends "$PACKAGE_NAME" || true

echo "--- Phase 2: Neutralizing post-install scripts ---"
# Создаем временную заглушку-пустышку
STUB="/tmp/true-stub"
printf '#!/bin/sh\nexit 0\n' > "$STUB"
chmod +x "$STUB"

# Ищем все .postinst скрипты для устанавливаемого пакета и заменяем их
# Мы ищем файлы, которые начинаются с имени пакета в /var/lib/dpkg/info/
find /var/lib/dpkg/info/ -name "${PACKAGE_NAME}*.postinst" -exec cp "$STUB" {} \;
# На всякий случай нейтрализуем и cron-daemon-common, если он прилетел прицепом
find /var/lib/dpkg/info/ -name "cron-daemon-common*.postinst" -exec cp "$STUB" {} \;

echo "--- Phase 3: Finalizing configuration ---"
# Теперь dpkg выполнит наши пустышки вместо реальных скриптов
dpkg --configure -a

echo "--- Done! Package $PACKAGE_NAME installed (scripts skipped) ---"


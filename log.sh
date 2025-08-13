#!/bin/bash

# Конфигурация
ALLOWED_USERS=("user1" "user2")  # Замените на реальные имена пользователей
LOG_DIR="/var/log/kind_collected"
TODAY=$(date +"%Y-%m-%d")

# Проверка пользователя
CURRENT_USER=$(whoami)
if ! printf '%s\n' "${ALLOWED_USERS[@]}" | grep -q "^${CURRENT_USER}$"; then
    echo "Ошибка: У вас нет прав для выполнения этого скрипта" >&2
    exit 1
fi

# Создаём директорию для логов (если не существует)
mkdir -p "${LOG_DIR}/${CURRENT_USER}"
chmod 700 "${LOG_DIR}/${CURRENT_USER}"

# Основная логика
docker exec kind-control-plane bash -c "/zxc.sh" || {
    echo "Ошибка выполнения zxc.sh в контейнере" >&2
    exit 1
}

docker exec kind-control-plane find / -maxdepth 1 -type f -name "log_${TODAY}-*_cursed-*.txt" 2>/dev/null | \
while read -r container_file; do
    filename=$(basename "${container_file}")
    
    # Парсинг имени файла
    if [[ $filename =~ log_(${TODAY}-[0-9]{2}-[0-9]{2})-[0-9]{2}_.*_cursed-(grand|small)-.*\.txt$ ]]; then
        new_name="${BASH_REMATCH[2]}_${BASH_REMATCH[1]}"
        output_path="${LOG_DIR}/${CURRENT_USER}/${new_name}"
        
        # Копирование и переименование
        docker cp "kind-control-plane:${container_file}" "${output_path}" && \
        echo "Логи сохранены: ${output_path}"
    fi
done

# Очистка старых логов (старше 3 дней)
find "${LOG_DIR}/${CURRENT_USER}" -type f -mtime +3 -delete

#!/bin/bash

# Ввод адреса для пинга
read -p "Введите адрес для пинга: " address

# Переменная для отслеживания неудачных попыток
failed_attempts=0

# Бесконечный цикл пинга
while true; do
    echo "Пингую $address..."

    # Выполняем пинг и извлекаем время
    output=$(ping -c 1 -W 1 "$address" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Не удалось выполнить пинг $address"
        ((failed_attempts++))
    else
        # Извлекаем время пинга
        ping_time=$(echo "$output" | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')

        if (( $(echo "$ping_time > 100" | bc -l) )); then
            echo "Предупреждение: время пинга ${ping_time} мс превышает 100 мс"
            failed_attempts=0
        else
            echo "Пинг успешен: ${ping_time} мс"
            failed_attempts=0
        fi
    fi

    # Проверяем количество неудачных попыток
    if [ $failed_attempts -ge 3 ]; then
        echo "Ошибка: не удалось выполнить пинг $address 3 раза подряд"
        break
    fi

    # Ожидание 1 секунды перед следующим пингом
    sleep 1
done

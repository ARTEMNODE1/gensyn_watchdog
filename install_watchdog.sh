#!/bin/bash

# === Конфигурация ===
NODE_DIR="$HOME/rl-swarm"
LOG_FILE="$NODE_DIR/gensynnode.log"
SCREEN_NAME="gensynnode"
TG_BOT_TOKEN="ВАШ_ТОКЕН"
TG_CHAT_ID="ВАШ_CHAT_ID"

# === Функция отправки в Telegram ===
send_alert() {
  message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d text="$message"
}

# === Основной Watchdog ===
while true; do
  sleep 15

  if ! screen -list | grep -q "$SCREEN_NAME"; then
    send_alert "🔴 Gensyn node упала. Перезапускаем..."

    cd "$NODE_DIR" || exit
    screen -dmS "$SCREEN_NAME" bash -c "source .venv/bin/activate && bash run_rl_swarm.sh 2>&1 | tee $LOG_FILE"

    sleep 10
    if screen -list | grep -q "$SCREEN_NAME"; then
      send_alert "✅ Gensyn node успешно перезапущена."
    else
      send_alert "⚠️ Ошибка при попытке перезапуска Gensyn node!"
    fi
  fi

done


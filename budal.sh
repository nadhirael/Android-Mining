#!/bin/bash
sudo apt install cpulimit -y
CONFIG_FILE="config.json"
MAX_MINERS=78

echo "🔹 Memulai $MAX_MINERS instance miner dengan 1 thread per miner..."
for ((i=0; i<MAX_MINERS; i++)); do
    CORE_ID=$i
    screen -dmS Miner$i taskset -c $CORE_ID ./ccminer -c $CONFIG_FILE
done

echo "🔹 Menjalankan CPU limit (90% per core)..."
pkill -f cpulimit  # Hentikan cpulimit sebelumnya (jika ada)
for pid in $(pgrep ccminer); do
    sudo cpulimit -p $pid -l 90 -b
done

echo "✅ Mining dimulai! Gunakan 'screen -r Miner1' atau 'screen -ls' untuk melihat log."

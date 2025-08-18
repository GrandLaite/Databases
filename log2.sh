#!/bin/bash

TODAY=$(date +%Y-%m-%d)
TEMP_DIR="/var/tmp/prelogs"
TARGET_DIR="/var/tmp/logs"

mkdir -p "$TEMP_DIR"
mkdir -p "$TARGET_DIR"

docker exec kind-control-plane find / -path /sys -prune -o -type f -name "log_${TODAY}*cursed*.txt" -exec rm -f {} +

docker exec kind-control-plane bash zxc.sh

docker exec kind-control-plane find / -path /sys -prune -o -type f -name "log_${TODAY}*cursed*.txt" -print | while read -r file; do
    docker cp "kind-control-plane:$file" "$TEMP_DIR"
done

rm -f "$TARGET_DIR"/*.txt

for file in "$TEMP_DIR"/log_${TODAY}*cursed*.txt; do
    filename=$(basename "$file")
    if [[ $filename =~ log_([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2})-[0-9]{2}_.*cursed-(grand|small).*\.txt ]]; then
        datetime="${BASH_REMATCH[1]}"
        type="${BASH_REMATCH[2]}"
        new_name="${type}_${datetime}.txt"
        mv "$file" "$TARGET_DIR/$new_name"
    fi
done

rm -f "$TEMP_DIR"/*

docker exec kind-control-plane find / \( -path /sys -o -path /proc -o -path /dev \) -prune -o -type f -name "log_${TODAY}*cursed*.txt" -exec rm -f {} +

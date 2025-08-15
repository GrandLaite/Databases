#!/bin/bash

TODAY=$(date +%Y-%m-%d)
TEMP_DIR="/var/tmp/prelogs"

docker exec -i kind-control-plane bash zxc.sh

docker exec kind-control-plane find / -path /sys -prune -o -type f -name "log_${TODAY}*cursed*.txt" -print | while read -r file; do
    docker cp "kind-control-plane:$file" "$TEMP_DIR"
done

for file in "$TEMP_DIR"/log_${TODAY}*cursed*.txt; do
    filename=$(basename "$file")
    if [[ $filename =~ log_([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2})-[0-9]{2}_.*cursed-(grand|small).*\.txt ]]; then
        datetime="${BASH_REMATCH[1]}"
        type="${BASH_REMATCH[2]}"
        new_name="${type}_${datetime}.log"
        mv "$file" "/var/tmp/logs/$new_name"
    fi
done

rm -f "$TEMP_DIR"/*

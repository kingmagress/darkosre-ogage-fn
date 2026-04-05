#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Targets
TARGET_MAIN="/usr/local/bin/ogage"
TARGET_SPK="/usr/local/bin/r36_config/ogage/ogage.SPK"
TARGET_SPK_HP="/usr/local/bin/r36_config/ogage/ogage.SPK_HP"

# Backup paths
BACKUP_MAIN="$SCRIPT_DIR/Ogage/ogage-original"
BACKUP_SPK="$SCRIPT_DIR/Ogage/ogage.SPK"
BACKUP_SPK_HP="$SCRIPT_DIR/Ogage/ogage.SPK_HP"

# Source binary
SOURCE_BIN="$SCRIPT_DIR/Ogage/ogage-fn"

backup_if_missing() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$dst" ]; then
        echo "Backing up $src → $dst"
        sudo cp -f "$src" "$dst"
    else
        echo "Backup exists: $dst"
    fi
}

echo "Stopping ogage service..."
sudo systemctl stop ogage.service

echo "=== Backup Phase ==="
backup_if_missing "$TARGET_MAIN" "$BACKUP_MAIN"
backup_if_missing "$TARGET_SPK" "$BACKUP_SPK"
backup_if_missing "$TARGET_SPK_HP" "$BACKUP_SPK_HP"

echo "=== Replace Phase ==="
sudo cp -f "$SOURCE_BIN" "$TARGET_MAIN"
sudo cp -f "$SOURCE_BIN" "$TARGET_SPK"
sudo cp -f "$SOURCE_BIN" "$TARGET_SPK_HP"

echo "Setting permissions..."
sudo chmod 777 "$TARGET_MAIN" "$TARGET_SPK" "$TARGET_SPK_HP"

echo "Restarting ogage service..."
sudo systemctl restart ogage.service

echo "Done. Persistent replacement applied."
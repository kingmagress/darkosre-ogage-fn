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

restore_if_exists() {
    local src="$1"
    local dst="$2"

    if [ -f "$src" ]; then
        echo "Restoring $dst from $src"
        sudo cp -f "$src" "$dst"
        sudo chmod 777 "$dst"
    else
        echo "Backup missing, cannot restore: $src"
    fi
}

echo "Stopping ogage service..."
sudo systemctl stop ogage.service

echo "=== Restore Phase ==="
restore_if_exists "$BACKUP_MAIN" "$TARGET_MAIN"
restore_if_exists "$BACKUP_SPK" "$TARGET_SPK"
restore_if_exists "$BACKUP_SPK_HP" "$TARGET_SPK_HP"

echo "Restarting ogage service..."
sudo systemctl start ogage.service

echo "Restore complete."
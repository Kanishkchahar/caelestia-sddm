#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script directly with sudo. Run: ./uninstall" >&2
    exit 1
fi

THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
CONFIG_DROPIN="/etc/sddm.conf.d/caelestia.conf"
BACKUP_DIR="/etc/sddm.conf.d/backups"
TEMPLATE_FILE="$HOME/.config/caelestia/templates/sddm-theme.conf"

echo "=================================================="
echo "          Caelestia SDDM Uninstaller"
echo "=================================================="
echo "This script requires sudo privileges to remove the theme."
if ! sudo -v; then
    echo "✗ Sudo authentication failed. Exiting."
    exit 1
fi
echo "✓ Sudo authenticated"

# 1. Clear SDDM greeter QML cache
echo "Clearing SDDM greeter QML cache..."
sudo rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
rm -rf "$HOME/.cache/sddm-greeter-qt6"
echo "✓ Cleared QML cache."

# 2. Remove the SDDM theme directory
echo "Removing theme directory ($THEME_DIR)..."
if [ -d "$THEME_DIR" ]; then
    sudo rm -rf "$THEME_DIR"
    echo "✓ Removed $THEME_DIR"
else
    echo "Theme directory not found, skipping."
fi

# 3. Remove SDDM configuration drop-in and restore backup if available
echo "Checking SDDM configuration..."
if [ -f "$CONFIG_DROPIN" ]; then
    sudo rm -f "$CONFIG_DROPIN"
    echo "✓ Removed $CONFIG_DROPIN"
fi

# Check for backup configuration to restore
LATEST_BACKUP=$(sudo find "$BACKUP_DIR" -type f -name "theme.conf.*" 2>/dev/null | sort -r | head -n 1 || true)
if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
    echo "Found previous backup: $LATEST_BACKUP"
    read -r -p "Do you want to restore this configuration? [y/N]: " restore_choice
    if [[ "$restore_choice" =~ ^[Yy]$ ]]; then
        sudo cp "$LATEST_BACKUP" /etc/sddm.conf.d/theme.conf
        echo "✓ Restored previous configuration."
    fi
fi

# 4. Clean user template
if [ -f "$TEMPLATE_FILE" ]; then
    rm -f "$TEMPLATE_FILE"
    echo "✓ Cleaned user template: $TEMPLATE_FILE"
fi

echo ""
echo "✅ Caelestia SDDM has been cleanly uninstalled."

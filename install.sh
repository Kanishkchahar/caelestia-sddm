#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run with sudo. The script asks for sudo when needed." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
THEME_NAME="caelestia"
INSTALL_DIR="/usr/share/sddm/themes/$THEME_NAME"
CONFIG_DROPIN="/etc/sddm.conf.d/caelestia.conf"

# ── Defaults ──────────────────────────────────────────────
DEFAULT_WALLPAPER="$SCRIPT_DIR/assets/background.jpg"
DEFAULT_AVATAR="$SCRIPT_DIR/assets/avatar.jpg"
DEFAULT_DISPLAY_NAME="Kanishk"

# ── Help ──────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
Caelestia SDDM Setup

Usage:
  ./install.sh [command]

Commands:
  (none)        Interactive setup — choose display name, wallpaper, and avatar
  preview       Preview theme in a test window without installing
  uninstall     Remove theme from system and restore previous SDDM config

Options:
  --help, -h    Show this help
EOF
    exit 0
}

# ── Preview ───────────────────────────────────────────────
do_preview() {
    echo "=================================================="
    echo "       Previewing Caelestia SDDM Theme"
    echo "=================================================="
    echo "Close the window or Ctrl+C to exit."
    export QML_XHR_ALLOW_FILE_READ=1
    if command -v sddm-greeter-qt6 &>/dev/null; then
        exec sddm-greeter-qt6 --test-mode --theme "$SCRIPT_DIR"
    elif command -v sddm-greeter &>/dev/null; then
        exec sddm-greeter --test-mode --theme "$SCRIPT_DIR"
    else
        echo "Error: sddm-greeter not found. Install SDDM first."
        exit 1
    fi
}

# ── Uninstall ─────────────────────────────────────────────
do_uninstall() {
    echo "=================================================="
    echo "        Caelestia SDDM Uninstaller"
    echo "=================================================="
    if ! sudo -v; then echo "✗ Sudo failed."; exit 1; fi

    sudo rm -rf "$INSTALL_DIR"
    sudo rm -f "$CONFIG_DROPIN"
    sudo rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
    rm -rf "$HOME/.cache/sddm-greeter-qt6"
    rm -f "$HOME/.config/caelestia/templates/sddm-theme.conf"
    echo "✅ Caelestia SDDM uninstalled."
    exit 0
}

# ── Parse command ─────────────────────────────────────────
case "${1:-}" in
    preview|-p)     do_preview ;;
    uninstall|-u)   do_uninstall ;;
    --help|-h)      show_help ;;
    "")             ;; # continue to interactive setup
    *)              echo "Unknown command: $1"; show_help ;;
esac

# ══════════════════════════════════════════════════════════
#               INTERACTIVE SETUP
# ══════════════════════════════════════════════════════════
echo "=================================================="
echo "          Caelestia SDDM Theme Setup"
echo "=================================================="
echo ""

# ── 1. Display Name ──────────────────────────────────────
echo "── Display Name ──"
echo "This name appears in the greeting (e.g. 'Good morning, Kanishk')."
echo "It also sets your Linux user's display name (GECOS field)."
read -r -p "Display name [$DEFAULT_DISPLAY_NAME]: " DISPLAY_NAME
DISPLAY_NAME="${DISPLAY_NAME:-$DEFAULT_DISPLAY_NAME}"
echo "✓ Display name: $DISPLAY_NAME"
echo ""

# ── 2. Wallpaper ──────────────────────────────────────────
echo "── Wallpaper ──"
echo "Enter the full path to a wallpaper image, or press Enter for default."
echo "Default: $DEFAULT_WALLPAPER"
read -r -e -p "Wallpaper path: " WALLPAPER_PATH
WALLPAPER_PATH="${WALLPAPER_PATH:-$DEFAULT_WALLPAPER}"

# Expand tilde
WALLPAPER_PATH="${WALLPAPER_PATH/#\~/$HOME}"

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "✗ File not found: $WALLPAPER_PATH"
    exit 1
fi

# Copy into assets if it's not already the default
if [ "$(realpath "$WALLPAPER_PATH")" != "$(realpath "$DEFAULT_WALLPAPER")" ]; then
    echo "Copying wallpaper into setup..."
    if command -v magick &>/dev/null; then
        magick "$WALLPAPER_PATH" -quality 95 "$SCRIPT_DIR/assets/background.jpg"
        echo "✓ Wallpaper optimized and saved as assets/background.jpg"
    else
        cp "$WALLPAPER_PATH" "$SCRIPT_DIR/assets/background.jpg"
        echo "✓ Wallpaper copied to assets/background.jpg"
    fi
else
    echo "✓ Using default wallpaper."
fi
echo ""

# ── 3. Profile Picture ───────────────────────────────────
echo "── Profile Picture ──"
echo "Enter the full path to a profile picture, or press Enter for default."
echo "Default: $DEFAULT_AVATAR"
read -r -e -p "Avatar path: " AVATAR_PATH
AVATAR_PATH="${AVATAR_PATH:-$DEFAULT_AVATAR}"

# Expand tilde
AVATAR_PATH="${AVATAR_PATH/#\~/$HOME}"

if [ ! -f "$AVATAR_PATH" ]; then
    echo "✗ File not found: $AVATAR_PATH"
    exit 1
fi

if [ "$(realpath "$AVATAR_PATH")" != "$(realpath "$DEFAULT_AVATAR")" ]; then
    echo "Copying avatar into setup..."
    cp "$AVATAR_PATH" "$SCRIPT_DIR/assets/avatar.jpg"
    echo "✓ Avatar saved as assets/avatar.jpg"
else
    echo "✓ Using default avatar."
fi
echo ""

# ── Confirm ──────────────────────────────────────────────
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo "  Display Name : $DISPLAY_NAME"
echo "  Wallpaper    : $WALLPAPER_PATH"
echo "  Avatar       : $AVATAR_PATH"
echo "=================================================="
echo ""
read -r -p "Proceed with installation? [Y/n]: " CONFIRM
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# ── Sudo ─────────────────────────────────────────────────
echo ""
if ! sudo -v; then echo "✗ Sudo failed."; exit 1; fi
echo "✓ Sudo authenticated"

# ── Dependencies ─────────────────────────────────────────
echo ""
echo "── Checking Dependencies ──"

PKGS=(
    "sddm"
    "qt6-declarative"
    "qt6-5compat"
    "qt6-svg"
    "qt6-multimedia"
    "ttf-material-symbols-variable"
    "ttf-roboto"
    "ttf-cascadia-code-nerd"
)

MISSING=()
for pkg in "${PKGS[@]}"; do
    pacman -Qi "$pkg" &>/dev/null || MISSING+=("$pkg")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "📦 Missing: ${MISSING[*]}"
    read -r -p "Install with pacman? [Y/n]: " INST
    if [[ -z "$INST" ]] || [[ "$INST" =~ ^[Yy]$ ]]; then
        sudo pacman -S --noconfirm "${MISSING[@]}"
    fi
else
    echo "✓ All dependencies installed."
fi

# AUR font (optional)
if ! pacman -Qi "ttf-rubik-vf" &>/dev/null && ! pacman -Qi "ttf-rubik" &>/dev/null; then
    echo "Notice: 'ttf-rubik-vf' recommended for better typography."
    if command -v yay &>/dev/null; then
        read -r -p "Install via yay? [Y/n]: " YN
        [[ -z "$YN" || "$YN" =~ ^[Yy]$ ]] && yay -S --noconfirm ttf-rubik-vf || true
    elif command -v paru &>/dev/null; then
        read -r -p "Install via paru? [Y/n]: " YN
        [[ -z "$YN" || "$YN" =~ ^[Yy]$ ]] && paru -S --noconfirm ttf-rubik-vf || true
    fi
fi

# ── Set Display Name ─────────────────────────────────────
echo ""
echo "── Setting Display Name ──"
sudo chfn -f "$DISPLAY_NAME" "$(whoami)" 2>/dev/null || true
echo "✓ Display name set to '$DISPLAY_NAME'"

# ── Install Theme ────────────────────────────────────────
echo ""
echo "── Installing Theme ──"

# Clean previous installation
[ -d "$INSTALL_DIR" ] && sudo rm -rf "$INSTALL_DIR"

# Copy theme files
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r \
    "$SCRIPT_DIR/Main.qml" \
    "$SCRIPT_DIR/metadata.desktop" \
    "$SCRIPT_DIR/theme.conf" \
    "$SCRIPT_DIR/assets" \
    "$SCRIPT_DIR/components" \
    "$SCRIPT_DIR/config" \
    "$SCRIPT_DIR/scripts" \
    "$INSTALL_DIR/"

echo "✓ Theme files copied to $INSTALL_DIR"

# ── Set Avatar System-Wide ───────────────────────────────
echo "Setting up avatar..."
REAL_HOME="$HOME"
cp "$SCRIPT_DIR/assets/avatar.jpg" "$REAL_HOME/.face"
chmod 644 "$REAL_HOME/.face"
ln -sf "$REAL_HOME/.face" "$REAL_HOME/.face.icon"

sudo mkdir -p /var/lib/AccountsService/icons
sudo cp "$SCRIPT_DIR/assets/avatar.jpg" "/var/lib/AccountsService/icons/$(whoami)"
sudo chmod 644 "/var/lib/AccountsService/icons/$(whoami)"

# Copy avatar into installed theme assets for SDDM access
sudo cp "$SCRIPT_DIR/assets/avatar.jpg" "$INSTALL_DIR/assets/avatar.face.icon"
sudo cp "$SCRIPT_DIR/assets/avatar.jpg" "$INSTALL_DIR/assets/avatar.face"
echo "✓ Avatar configured"

# ── Set Permissions ──────────────────────────────────────
sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} +
sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} +
[ -f "$INSTALL_DIR/scripts/sync.sh" ] && sudo chmod 755 "$INSTALL_DIR/scripts/sync.sh"

# ── Configure SDDM ──────────────────────────────────────
echo "Configuring SDDM..."
sudo mkdir -p /etc/sddm.conf.d
cat <<'EOF' | sudo tee "$CONFIG_DROPIN" >/dev/null
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1,QT_QPA_PLATFORM=xcb

[Theme]
Current=caelestia
EOF

# Override any other theme.conf
if [ -f /etc/sddm.conf.d/theme.conf ]; then
    sudo sed -i 's/^Current=.*/Current=caelestia/' /etc/sddm.conf.d/theme.conf
fi
echo "✓ SDDM configured"

# ── Clear Cache ──────────────────────────────────────────
sudo rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
rm -rf "$HOME/.cache/sddm-greeter-qt6"

# ── Run Sync ─────────────────────────────────────────────
if [ -x "$INSTALL_DIR/scripts/sync.sh" ]; then
    sudo "$INSTALL_DIR/scripts/sync.sh" 2>/dev/null || true
fi

echo ""
echo "=================================================="
echo "  ✅ Caelestia SDDM Installed!"
echo "=================================================="
echo ""
echo "  Display Name : $DISPLAY_NAME"
echo "  Theme Active : $THEME_NAME"
echo ""
echo "  Preview:    ./install.sh preview"
echo "  Uninstall:  ./install.sh uninstall"
echo ""

read -r -p "Preview the theme now? [Y/n]: " TEST
if [[ -z "$TEST" ]] || [[ "$TEST" =~ ^[Yy]$ ]]; then
    do_preview
fi

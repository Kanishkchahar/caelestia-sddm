#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script directly with sudo. Run: ./install" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
THEME_NAME="caelestia"
INSTALL_DIR="/usr/share/sddm/themes/$THEME_NAME"
BACKUP_DIR="/etc/sddm.conf.d/backups"
CONFIG_DROPIN="/etc/sddm.conf.d/caelestia.conf"

show_help() {
    cat << 'EOF'
Caelestia SDDM Installer

Usage:
  ./install [options]

Options:
  -p, --preview          Preview theme in test window without installing
  -u, --uninstall        Uninstall the theme and restore previous configuration
  --no-deps              Skip installing package manager dependencies & fonts
  -h, --help             Show this help message
EOF
    exit 0
}

# Parse options
SKIP_DEPS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--preview)
            exec "$SCRIPT_DIR/preview.sh"
            ;;
        -u|--uninstall)
            exec "$SCRIPT_DIR/uninstall.sh"
            ;;
        --no-deps)
            SKIP_DEPS=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

echo "=================================================="
echo "          Caelestia SDDM Theme Setup"
echo "=================================================="
echo "Installing your personalized Caelestia SDDM setup..."
echo ""

# Sudo verification
echo "Checking sudo permissions..."
if ! sudo -v; then
    echo "✗ Sudo authentication failed. Exiting."
    exit 1
fi
echo "✓ Sudo authenticated"

# Dependency check
if [ "$SKIP_DEPS" = false ]; then
    echo ""
    echo "--- Checking Dependencies ---"

    SDDM_DEPS=(
        "sddm"
        "qt6-declarative"
        "qt6-5compat"
        "qt6-svg"
        "qt6-multimedia"
    )

    OFFICIAL_FONTS=(
        "ttf-material-symbols-variable"
        "ttf-roboto"
        "ttf-cascadia-code-nerd"
    )

    MISSING_PKGS=()
    if command -v pacman &>/dev/null; then
        for pkg in "${SDDM_DEPS[@]}" "${OFFICIAL_FONTS[@]}"; do
            if ! pacman -Qi "$pkg" &>/dev/null; then
                MISSING_PKGS+=("$pkg")
            fi
        done

        if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
            echo "📦 Missing system packages/fonts: ${MISSING_PKGS[*]}"
            read -r -p "Install missing packages with pacman? [Y/n]: " install_deps
            if [[ -z "$install_deps" ]] || [[ "$install_deps" =~ ^[Yy]$ ]]; then
                sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
            fi
        else
            echo "✓ Core SDDM packages and fonts installed."
        fi

        # Check AUR font
        if ! pacman -Qi "ttf-rubik-vf" &>/dev/null && ! pacman -Qi "ttf-rubik" &>/dev/null; then
            echo "Notice: 'ttf-rubik-vf' is recommended for Caelestia SDDM typography."
            if command -v yay &>/dev/null; then
                read -r -p "Install 'ttf-rubik-vf' via yay? [Y/n]: " install_aur_font
                if [[ -z "$install_aur_font" ]] || [[ "$install_aur_font" =~ ^[Yy]$ ]]; then
                    yay -S --noconfirm ttf-rubik-vf || true
                fi
            elif command -v paru &>/dev/null; then
                read -r -p "Install 'ttf-rubik-vf' via paru? [Y/n]: " install_aur_font
                if [[ -z "$install_aur_font" ]] || [[ "$install_aur_font" =~ ^[Yy]$ ]]; then
                    paru -S --noconfirm ttf-rubik-vf || true
                fi
            fi
        fi
    fi
fi

REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Backup existing configuration
sudo mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -f "$CONFIG_DROPIN" ]; then
    echo "Backing up existing SDDM drop-in..."
    sudo cp "$CONFIG_DROPIN" "$BACKUP_DIR/caelestia.conf.$TIMESTAMP"
fi

if [ -f /etc/sddm.conf.d/theme.conf ]; then
    echo "Backing up other active theme.conf..."
    sudo cp /etc/sddm.conf.d/theme.conf "$BACKUP_DIR/theme.conf.$TIMESTAMP"
fi

# Clean previous installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing theme installation..."
    sudo rm -rf "$INSTALL_DIR"
fi

# Copy theme to destination
echo "Copying theme files to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

# Copy all theme files (excluding git and installation scripts)
sudo cp -r \
    "$SCRIPT_DIR/Main.qml" \
    "$SCRIPT_DIR/metadata.desktop" \
    "$SCRIPT_DIR/theme.conf" \
    "$SCRIPT_DIR/assets" \
    "$SCRIPT_DIR/components" \
    "$SCRIPT_DIR/config" \
    "$SCRIPT_DIR/widgets" \
    "$SCRIPT_DIR/scripts" \
    "$INSTALL_DIR/"

# Setup avatar in AccountsService & theme
if [ -f "$SCRIPT_DIR/assets/avatar.jpg" ]; then
    echo "Setting user avatar..."
    sudo mkdir -p /var/lib/AccountsService/icons
    sudo cp "$SCRIPT_DIR/assets/avatar.jpg" "/var/lib/AccountsService/icons/$REAL_USER"
    sudo chmod 644 "/var/lib/AccountsService/icons/$REAL_USER"

    cp "$SCRIPT_DIR/assets/avatar.jpg" "$REAL_HOME/.face"
    chmod 644 "$REAL_HOME/.face"
    ln -sf "$REAL_HOME/.face" "$REAL_HOME/.face.icon"
fi

# Create user color template configuration
mkdir -p "$REAL_HOME/.config/caelestia/templates"
if [ -f "$SCRIPT_DIR/theme.conf.template" ]; then
    cp "$SCRIPT_DIR/theme.conf.template" "$REAL_HOME/.config/caelestia/templates/sddm-theme.conf"
    echo "✓ Template created at ~/.config/caelestia/templates/sddm-theme.conf"
fi

# Set proper permissions
sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} +
sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} +
if [ -f "$INSTALL_DIR/scripts/sync.sh" ]; then
    sudo chmod 755 "$INSTALL_DIR/scripts/sync.sh"
fi

# Configure SDDM drop-in so ONLY Caelestia is active
echo "Configuring SDDM (/etc/sddm.conf.d/caelestia.conf)..."
sudo mkdir -p /etc/sddm.conf.d
cat <<'EOF' | sudo tee "$CONFIG_DROPIN" >/dev/null
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1,QT_QPA_PLATFORM=xcb

[Theme]
Current=caelestia
EOF

# Ensure no other config in /etc/sddm.conf.d overrides Current
if [ -f /etc/sddm.conf.d/theme.conf ]; then
    sudo sed -i 's/^Current=.*/Current=caelestia/' /etc/sddm.conf.d/theme.conf
fi

# Clear SDDM greeter cache
echo "Clearing SDDM greeter cache..."
sudo rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
rm -rf "$REAL_HOME/.cache/sddm-greeter-qt6"

# Run initial sync script
if [ -x "$INSTALL_DIR/scripts/sync.sh" ]; then
    echo "Running sync script..."
    sudo "$INSTALL_DIR/scripts/sync.sh" || true
fi

echo ""
echo "=================================================="
echo "✅ Caelestia SDDM Successfully Installed as Active Theme!"
echo "=================================================="
echo ""

read -r -p "Would you like to preview the theme in a test window now? [Y/n]: " test_now
if [[ -z "$test_now" ]] || [[ "$test_now" =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/preview.sh"
fi

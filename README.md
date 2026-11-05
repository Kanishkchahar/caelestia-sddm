# Caelestia SDDM

A clean, modern, and lightweight SDDM login screen theme with custom wallpaper, avatar integration, and adaptive high-resolution display scaling.

![Preview](preview.jpg)

---

## ✨ Features

- **Direct Login:** Lands directly on the password interface ready for typing with zero splash screen delays.
- **Adaptive HiDPI Scaling:** Responsive card scaling that automatically looks balanced on 1080p, 1440p, and 4K displays.
- **System Fetch Widget:** Built-in `caelestiafetch.sh` widget displaying your session, username, OS, and hostname.
- **Clock & Dynamic Quotes:** Clean digital clock with date, alongside inspirational quotes and offline dino widget.
- **Custom Wallpaper & Avatar:** Easy interactive setup for custom backgrounds and profile photos.
- **Power Controls:** Integrated shutdown and reboot buttons.

---

## 🚀 Installation

```bash
git clone https://github.com/Kanishkchahar/caelestia-sddm.git
cd caelestia-sddm
./install.sh
```

The installer will interactively prompt you to:
1. **Choose a wallpaper** — enter the path to any image, or press Enter for the default
2. **Choose a profile picture** — enter the path to your avatar, or press Enter for the default

It automatically checks and installs dependencies, fonts, SDDM configuration, and permissions.

---

## 🔄 Quick Update

If you already have the theme installed and just want to update the theme files without re-selecting your wallpaper or avatar:

```bash
./install.sh update
```

---

## 🖥️ Preview Without Rebooting

Test the theme in a preview window anytime:

```bash
./install.sh preview
```

---

## 🎨 Customization

After installation, customize your setup anytime:

- **Card Size / Scaling:** Edit `cardScale` in `theme.conf` (e.g. `1.18` default, adjust higher or lower to taste)
- **Wallpaper:** Replace `assets/background.jpg` or re-run `./install.sh`
- **Avatar:** Replace `assets/avatar.jpg` or re-run `./install.sh`
- **Colors & Blur:** Tweak blur amounts, opacities, and palette colors in `theme.conf`

---

## 🗑️ Uninstall

To remove the theme and restore previous SDDM configuration:

```bash
./install.sh uninstall
```

---

## 📦 Requirements

- **Display Manager:** `sddm`
- **Qt6 Packages:** `qt6-declarative`, `qt6-5compat`, `qt6-svg`, `qt6-multimedia`
- **Fonts:**
  - `ttf-material-symbols-variable`
  - `ttf-roboto`
  - `ttf-cascadia-code-nerd`
  - `ttf-rubik-vf` (optional/recommended)

> All dependencies are automatically checked and installed by `./install.sh` on Arch Linux.

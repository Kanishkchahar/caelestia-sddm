# Caelestia SDDM

A clean, modern, and lightweight SDDM login screen theme with custom wallpaper and avatar integration.

![Caelestia SDDM Preview](preview.jpg)

---

## ✨ Features

- **Modern Aesthetic:** Clean lockscreen layout with date, clock, greeting, and system power controls.
- **Custom Wallpaper & Avatar:** Pre-configured with custom high-resolution background and profile picture.
- **Lightweight & Fast:** Pure Qt6 QML with optimized assets, fast startup, and zero background overhead.
- **One-Command Setup:** Automated installer handles dependencies, SDDM configuration, permissions, and greeter caching.

---

## 🚀 Installation

### 1. Clone & Enter
```bash
git clone https://github.com/Kanishkchahar/caelestia-sddm.git
cd caelestia-sddm
```
*(Or navigate to this folder if downloaded locally).*

### 2. Run the Installer
```bash
./install.sh
```

The installer will:
1. Check and install any missing system dependencies and fonts.
2. Back up any existing SDDM configurations.
3. Install the theme to `/usr/share/sddm/themes/caelestia`.
4. Configure `/etc/sddm.conf.d/caelestia.conf` to set Caelestia as your active login screen.
5. Set up your profile avatar and clear the greeter cache.

---

## 🖥️ Preview Without Rebooting

You can safely test the theme in a preview window anytime without logging out:

```bash
./preview.sh
```

---

## 🎨 Customization

- **Wallpaper:** Replace `assets/background.jpg` with any image of your choice.
- **User Avatar:** Replace `assets/avatar.jpg` with your profile photo.
- **Colors & Options:** Edit `theme.conf` to tweak clocks, blur, or colors.

After changing assets, simply run `./install.sh` again to update your login screen.

---

## 🗑️ Uninstallation

To remove the theme and restore your previous SDDM configuration:

```bash
./install.sh --uninstall
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

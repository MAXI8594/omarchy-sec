#!/bin/bash

# ==============================================================================
# Omarchy Sec - Standalone 1-Click Installer
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="$HOME/.local/bin"
TARGET_PLUGIN="$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-sec"
TARGET_SYSTEMD="$HOME/.config/systemd/user"

echo "=========================================================="
echo " 🛡️ Instalando Omarchy Sec & AI Incident Bridge"
echo "=========================================================="

mkdir -p "$TARGET_BIN" "$TARGET_PLUGIN" "$TARGET_SYSTEMD"

# 1. Instalar binarios CLI
echo "[*] Instalando binarios en $TARGET_BIN..."
cp "$BASE_DIR/bin/"* "$TARGET_BIN/"
chmod +x "$TARGET_BIN/omarchy-sec"*

# 2. Instalar Plugin de Barra en Quickshell
echo "[*] Instalando plugin de barra en $TARGET_PLUGIN..."
cp "$BASE_DIR/manifest.json" "$BASE_DIR/"*.qml "$BASE_DIR/"*.js "$TARGET_PLUGIN/"

# 3. Instalar y habilitar servicio systemd del observador
echo "[*] Configurando servicio systemd de usuario (omarchy-sec-watcher.service)..."
cp "$BASE_DIR/systemd/omarchy-sec-watcher.service" "$TARGET_SYSTEMD/"
systemctl --user daemon-reload
systemctl --user enable --now omarchy-sec-watcher.service || true

# 4. Validar plugin
echo "[*] Validando plugin con Omarchy CLI..."
omarchy plugin validate "$TARGET_PLUGIN"

echo ""
echo "=========================================================="
echo " ✅ ¡Instalación completada con éxito!"
echo " 👉 El widget 'Omarchy Sec' ya está activo en tu barra."
echo " 👉 Ejecuta 'omarchy-sec' en tu terminal para ver opciones."
echo "=========================================================="

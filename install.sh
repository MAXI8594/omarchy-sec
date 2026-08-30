#!/bin/bash

# ==============================================================================
# Omarchy Wazuh Security Suite - One-Click Installer
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-wazuh"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SHELL_CONFIG="$HOME/.config/omarchy/shell.json"

echo "=========================================================="
echo " 🛡️ Instalando Omarchy Wazuh Security & AI Incident Bridge"
echo "=========================================================="

# 1. Crear directorios
mkdir -p "$BIN_DIR" "$PLUGIN_DIR" "$SYSTEMD_USER_DIR"

# 2. Instalar binarios CLI
echo "[*] Instalando scripts en $BIN_DIR..."
cp "$BASE_DIR/bin/"* "$BIN_DIR/"
chmod +x "$BIN_DIR/omarchy-security-incident" "$BIN_DIR/omarchy-wazuh-watcher"

# 3. Instalar Plugin de Quickshell
echo "[*] Instalando plugin de barra en $PLUGIN_DIR..."
cp -r "$BASE_DIR/plugin/"* "$PLUGIN_DIR/"

# 4. Configurar servicio de usuario en systemd
echo "[*] Configurando servicio systemd de usuario..."
cp "$BASE_DIR/systemd/omarchy-wazuh-watcher.service" "$SYSTEMD_USER_DIR/"
systemctl --user daemon-reload
systemctl --user enable --now omarchy-wazuh-watcher.service

# 5. Insertar widget en shell.json si no existe
if [ -f "$SHELL_CONFIG" ]; then
  if ! grep -q "io.github.maxi8594.omarchy-wazuh" "$SHELL_CONFIG"; then
    echo "[*] Agregando widget a la barra de Omarchy en $SHELL_CONFIG..."
    sed -i 's/"id": "omarchy.tray"/"id": "omarchy.tray"},\n        {\n          "id": "io.github.maxi8594.omarchy-wazuh"/' "$SHELL_CONFIG" || true
  fi
fi

# 6. Recargar plugins de la barra
if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins 2>/dev/null || true
fi

echo "=========================================================="
echo " ✅ Instalación finalizada con éxito."
echo " Dashboard disponible en: https://localhost:9001"
echo " Widget disponible en la barra superior de Omarchy."
echo "=========================================================="

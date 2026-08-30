#!/bin/bash

# ==============================================================================
# Omarchy Wazuh Security Suite - Uninstaller
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " 🗑️ Desinstalando Omarchy Wazuh Security & AI Bridge"
echo "=========================================================="

# 1. Detener y deshabilitar servicio systemd
systemctl --user disable --now omarchy-wazuh-watcher.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/omarchy-wazuh-watcher.service"
systemctl --user daemon-reload

# 2. Remover binarios
rm -f "$HOME/.local/bin/omarchy-security-incident"
rm -f "$HOME/.local/bin/omarchy-wazuh-watcher"

# 3. Remover plugin de Quickshell
rm -rf "$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-wazuh"

# 4. Limpiar shell.json
if [ -f "$HOME/.config/omarchy/shell.json" ]; then
  sed -i '/io.github.maxi8594.omarchy-wazuh/d' "$HOME/.config/omarchy/shell.json" 2>/dev/null || true
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins 2>/dev/null || true
fi

echo "✅ Desinstalación completada."

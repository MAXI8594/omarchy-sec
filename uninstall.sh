#!/bin/bash

# ==============================================================================
# Omarchy Sec - Uninstaller
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " 🗑️ Desinstalando Omarchy Sec"
echo "=========================================================="

# 1. Detener y deshabilitar servicio systemd
systemctl --user disable --now omarchy-sec-watcher.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/omarchy-sec-watcher.service"
systemctl --user daemon-reload

# 2. Remover binarios
rm -f "$HOME/.local/bin/omarchy-sec"*

# 3. Remover plugins
rm -rf "$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-sec"
rm -rf "$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-wazuh"

# 4. Limpiar shell.json
if [ -f "$HOME/.config/omarchy/shell.json" ]; then
  sed -i '/io.github.maxi8594.omarchy-sec/d' "$HOME/.config/omarchy/shell.json" 2>/dev/null || true
  sed -i '/io.github.maxi8594.omarchy-wazuh/d' "$HOME/.config/omarchy/shell.json" 2>/dev/null || true
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins 2>/dev/null || true
fi

echo "✅ Desinstalación completada."

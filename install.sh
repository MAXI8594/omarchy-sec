#!/bin/bash

# ==============================================================================
# Omarchy Sec - Standalone 1-Click Installer
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="$HOME/.local/bin"
TARGET_SYSTEMD="$HOME/.config/systemd/user"
PLUGIN_REPO="https://github.com/MAXI8594/omarchy-sec-plugin.git"

echo "=========================================================="
echo " 🛡️ Instalando Omarchy Sec & AI Incident Bridge"
echo "=========================================================="

mkdir -p "$TARGET_BIN" "$TARGET_SYSTEMD"

# 1. Instalar binarios CLI
echo "[*] Instalando binarios en $TARGET_BIN..."
cp "$BASE_DIR/bin/"* "$TARGET_BIN/"
chmod +x "$TARGET_BIN/omarchy-sec"*

# 2. El widget de barra vive en su propio repo (requisito del marketplace:
#    un repositorio publico por plugin). No lo copiamos desde aca: tener una
#    segunda copia del QML garantiza que las dos versiones diverjan.
echo "[*] Instalando el widget de barra desde $PLUGIN_REPO..."
if omarchy plugin list --json 2>/dev/null | grep -q "io.github.maxi8594.omarchy-sec"; then
  omarchy plugin update io.github.maxi8594.omarchy-sec --yes || true
else
  omarchy plugin add "$PLUGIN_REPO" --enable --yes || {
    echo "  [!] No se pudo instalar el widget automaticamente. Instalalo con:"
    echo "      omarchy plugin add $PLUGIN_REPO --enable"
  }
fi

# 3. Instalar y habilitar servicio systemd del observador
# El unit versionado apunta a /usr/bin porque es el que empaqueta el AUR
# (ver packaging/aur/). Esta instalacion desde el checkout deja los binarios en
# ~/.local/bin, asi que reescribimos el ExecStart al copiarlo.
echo "[*] Configurando servicio systemd de usuario (omarchy-sec-watcher.service)..."
sed "s|^ExecStart=.*|ExecStart=$TARGET_BIN/omarchy-sec-watcher|" \
  "$BASE_DIR/systemd/omarchy-sec-watcher.service" > "$TARGET_SYSTEMD/omarchy-sec-watcher.service"
systemctl --user daemon-reload
systemctl --user enable --now omarchy-sec-watcher.service || true


echo ""
echo "=========================================================="
echo " ✅ ¡Instalación completada con éxito!"
echo " 👉 El widget 'Omarchy Sec' ya está activo en tu barra."
echo " 👉 Ejecuta 'omarchy-sec' en tu terminal para ver opciones."
echo "=========================================================="

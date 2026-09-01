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
echo " Este script instala el CLI y el servicio de fondo sin pedir"
echo " privilegios. El widget de la barra necesita ademas el paquete"
echo " AUR (root); mas abajo se explica por que y como hacerlo."
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

# 3. Servicio systemd del observador
# El paquete instala su unit en /usr/lib/systemd/user/. Un unit propio en
# ~/.config/systemd/user/ lo TAPA, y como apunta a ~/.local/bin el servicio
# seguiria corriendo la copia del checkout aun despues de un 'pacman -Syu'.
# Dos copias del mismo binario siempre terminan divergiendo, y en una herramienta
# de seguridad esa divergencia es silenciosa.
PKG_UNIT="/usr/lib/systemd/user/omarchy-sec-watcher.service"
USER_UNIT="$TARGET_SYSTEMD/omarchy-sec-watcher.service"

if [ -f "$PKG_UNIT" ]; then
  echo "[*] El paquete ya provee el servicio; no se instala una copia de usuario."
  if [ -f "$USER_UNIT" ]; then
    echo "    Quitando el unit de usuario que tapaba al del paquete..."
    rm -f "$USER_UNIT"
  fi
  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-sec-watcher.service || true
else
  echo "[*] Configurando servicio systemd de usuario (omarchy-sec-watcher.service)..."
  sed "s|^ExecStart=.*|ExecStart=$TARGET_BIN/omarchy-sec-watcher|" \
    "$BASE_DIR/systemd/omarchy-sec-watcher.service" > "$USER_UNIT"
  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-sec-watcher.service || true
fi


echo ""
echo "=========================================================="
echo " ✅ CLI y servicio instalados"
echo "=========================================================="
echo " 👉 Ejecuta 'omarchy-sec' en tu terminal para ver opciones."
echo " 👉 omarchy-sec-watcher corriendo como servicio systemd --user."
echo ""
echo "=========================================================="
echo " ⚠️  El widget 'Omarchy Sec' va a quedar en gris"
echo "=========================================================="
echo " Motivo: por un pedido de seguridad del marketplace, el widget"
echo " solo ejecuta /usr/bin/omarchy-sec-detect y /usr/bin/omarchy-sec,"
echo " y exige que sean archivos de root (sin symlinks ni permisos de"
echo " escritura de grupo/otros). ~/.local/bin es escribible por vos,"
echo " asi que el widget lo rechaza a proposito: validar una ruta y"
echo " despues ejecutarla (check-then-execute) no es seguro si esa"
echo " ruta la puede reemplazar cualquier proceso con tu usuario."
echo ""
echo " Este script nunca va a copiar binarios a /usr/bin con sudo"
echo " escondido. Para que el widget funcione, instala el paquete"
echo " (que sí coloca los binarios en /usr/bin, propiedad de root):"
echo ""
echo "     cd \"$BASE_DIR/packaging/aur\" && makepkg -si"
echo ""
echo " makepkg te va a pedir la contraseña de sudo: corre ese comando"
echo " vos mismo en una terminal real, no falta agregarlo a este script."
echo " Mas detalle en packaging/aur/README.md."
echo ""
echo " Nota: 'omarchy-sec' en tu terminal seguira resolviendo la copia"
echo " de ~/.local/bin (tu PATH la encuentra antes que /usr/bin); eso"
echo " es normal y no afecta al widget, que solo mira /usr/bin."
echo "=========================================================="

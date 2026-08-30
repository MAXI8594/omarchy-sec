#!/bin/bash

# ==============================================================================
# Omarchy Sec - GitHub Wiki Automated Publisher
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIKI_DIR="$BASE_DIR/wiki"
TMP_WIKI="/tmp/omarchy-sec-wiki-sync"
WIKI_REPO="https://github.com/MAXI8594/omarchy-sec.wiki.git"

echo "=========================================================="
echo " 📚 Publicando Wiki de Omarchy Sec en GitHub..."
echo "=========================================================="

rm -rf "$TMP_WIKI"
mkdir -p "$TMP_WIKI"

if git clone "$WIKI_REPO" "$TMP_WIKI" 2>/dev/null; then
  cd "$TMP_WIKI"
  cp "$WIKI_DIR/"*.md "$TMP_WIKI/"
  git add .
  if git diff --cached --quiet; then
    echo "ℹ La Wiki ya está actualizada en GitHub."
  else
    git commit -m "docs(wiki): update comprehensive Omarchy Sec wiki documentation"
    git push origin master || git push origin main
    echo "✅ Wiki publicada y sincronizada con éxito en GitHub!"
  fi
else
  echo ""
  echo "ℹ Para inicializar la Wiki en GitHub por primera vez:"
  echo "  1. Abre https://github.com/MAXI8594/omarchy-sec/wiki en tu navegador."
  echo "  2. Haz click en el botón verde 'Create the first page' y guárdala."
  echo "  3. Vuelve a ejecutar este script: ./scripts/publish-wiki.sh"
  echo ""
  echo "Todos los archivos de la wiki están guardados en tu repositorio en la carpeta 'wiki/'."
fi

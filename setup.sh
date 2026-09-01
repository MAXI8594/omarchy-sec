#!/bin/bash

# ==============================================================================
# Omarchy Wazuh Security Suite - Interactive Setup & Deployment Wizard
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${WAZUH_PORT:-9001}"
ENV_FILE="$BASE_DIR/docker/single-node/.env"
INTERNAL_USERS_FILE="$BASE_DIR/docker/single-node/config/wazuh_indexer/internal_users.yml"
WAZUH_DASHBOARD_YML="$BASE_DIR/docker/single-node/config/wazuh_dashboard/wazuh.yml"
INDEXER_IMAGE="wazuh/wazuh-indexer:4.14.7"
# Config del CLI (bin/omarchy-sec-wazuh-api), instalado vía AUR en /usr/bin —
# no puede asumir que existe el checkout del repo, así que vive en el HOME
# del usuario, separado del .env de docker/.
CLI_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-sec/env"

# Genera credenciales aleatorias en docker/single-node/.env la primera vez que
# se corre el script (nunca se commitean, ver .gitignore). INDEXER_PASSWORD y
# DASHBOARD_PASSWORD requieren un hash bcrypt propio en internal_users.yml —
# lo recalculamos con la misma herramienta que usa wazuh-docker upstream
# (plugins/opensearch-security/tools/hash.sh) corriendo en un contenedor
# efímero, sin necesidad de tocar el stack si ya está levantado. wazuh.yml
# (config que el dashboard usa para hablarle a la API del manager) está
# bind-mounteado, así que Compose NO interpola ${API_PASSWORD} dentro de su
# contenido: hay que reescribirlo con sed igual que los hashes.
generate_password() {
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32
}

generate_bcrypt_hash() {
  docker run --rm \
    --entrypoint /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh \
    -e OPENSEARCH_JAVA_HOME=/usr/share/wazuh-indexer/jdk \
    "$INDEXER_IMAGE" -p "$1" 2>/dev/null | tr -d '\r\n'
}

setup_credentials() {
  if [ -f "$ENV_FILE" ]; then
    return 0
  fi

  echo -e "\n\e[1;34m[*] Generando credenciales aleatorias (primera ejecución)...\e[0m"

  local indexer_password api_password dashboard_password admin_hash kibanaserver_hash
  indexer_password=$(generate_password)
  api_password=$(generate_password)
  dashboard_password=$(generate_password)

  echo "  - Calculando hashes bcrypt para el indexer (puede tardar unos segundos)..."
  admin_hash=$(generate_bcrypt_hash "$indexer_password")
  kibanaserver_hash=$(generate_bcrypt_hash "$dashboard_password")

  if [ -z "$admin_hash" ] || [ -z "$kibanaserver_hash" ]; then
    echo "  [!] No se pudo calcular el hash bcrypt (¿Docker no disponible?)."
    echo "      Copiá docker/single-node/.env.example a .env y completá los valores"
    echo "      a mano (ver docker/single-node/README.md, sección Credentials)."
    return 1
  fi

  sed -i "/^admin:\$/,/hash:/{s|hash: \".*\"|hash: \"$admin_hash\"|}" "$INTERNAL_USERS_FILE"
  sed -i "/^kibanaserver:\$/,/hash:/{s|hash: \".*\"|hash: \"$kibanaserver_hash\"|}" "$INTERNAL_USERS_FILE"
  sed -i "/username: wazuh-wui/,/password:/{s|password: \".*\"|password: \"$api_password\"|}" "$WAZUH_DASHBOARD_YML"

  cat > "$ENV_FILE" <<EOF_ENV
# Generado automáticamente por setup.sh el $(date -Iseconds). No commitear.
INDEXER_PASSWORD=$indexer_password
API_PASSWORD=$api_password
DASHBOARD_PASSWORD=$dashboard_password
EOF_ENV
  chmod 600 "$ENV_FILE"

  if [ ! -f "$CLI_CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CLI_CONFIG_FILE")"
    cat > "$CLI_CONFIG_FILE" <<EOF_CLI
# Generado automáticamente por setup.sh el $(date -Iseconds).
# Usado por bin/omarchy-sec-wazuh-api para autenticar contra la API (:55000).
WAZUH_API_USER=wazuh-wui
WAZUH_API_PASS=$api_password
EOF_CLI
    chmod 600 "$CLI_CONFIG_FILE"
  fi

  echo -e "  \e[1;32m✓\e[0m Credenciales guardadas en \e[1m$ENV_FILE\e[0m y \e[1m$CLI_CONFIG_FILE\e[0m (permisos 600)."
}

echo -e "\e[1;36m======================================================================\e[0m"
echo -e "\e[1;36m 🛡️  OMARCHY ENDPOINT SECURITY & WAZUH EDR SETUP WIZARD              \e[0m"
echo -e "\e[1;36m======================================================================\e[0m"
echo ""
echo -e "Este asistente instala y configura el stack de seguridad para tu estación Omarchy:"
echo -e " • \e[1;32mEDR / XDR:\e[0m Detección de amenazas, reverse shells y anomalías en memoria."
echo -e " • \e[1;32mFIM:\e[0m Integridad de archivos en /etc, /usr/bin, /usr/sbin, /bin, /sbin y /boot."
echo -e "        (\e[1;33mOjo:\e[0m \$HOME no se monitorea por defecto. Para cubrir ~/.config/hypr"
echo -e "        hay que agregarlo al bloque syscheck del agente en /var/ossec/etc/ossec.conf.)"
echo -e " • \e[1;32mSCA:\e[0m Evaluación continua contra benchmarks de seguridad CIS."
echo -e " • \e[1;32mSOC Dashboard:\e[0m Consola web en modo oscuro en https://localhost:$PORT"
echo -e " • \e[1;32mAI Bridge:\e[0m Despacho automático de incidentes al Agente de Omarchy."
echo ""

# 1. Escaneo de sensores existentes
echo -e "\e[1;33m[*] Verificando sensores de seguridad existentes en el sistema...\e[0m"
detection_json=$("$BASE_DIR/bin/omarchy-sec-detect")
primary_sensor=$(echo "$detection_json" | jq -r '.primary')
active_count=$(echo "$detection_json" | jq -r '.activeCount')

if [ "$active_count" -gt 0 ]; then
  echo -e "  ✓ Sensor detectado: \e[1;32m$primary_sensor\e[0m"
else
  echo -e "  ℹ No se detectaron sensores comerciales (Falcon, Cortex, Defender)."
fi

echo ""
read -p "¿Deseas proceder con la instalación/actualización de Wazuh EDR? [S/n]: " -r response
response=${response:-S}
if [[ ! "$response" =~ ^([sS][iI]?|[yY][eE]?[sS]?)$ ]]; then
  echo "Instalación cancelada."
  exit 0
fi

# 2. Despliegue de Docker Stack
setup_credentials
echo -e "\n\e[1;34m[1/4] Levantando contenedores de Wazuh (Manager, Indexer, Dashboard)...\e[0m"
if [ -d "$BASE_DIR/docker/single-node" ]; then
  cd "$BASE_DIR/docker/single-node"
  docker compose up -d
else
  echo "[!] Directorio docker/single-node no encontrado."
fi

# 3. Instalación de binarios y plugin de Omarchy
echo -e "\n\e[1;34m[2/4] Instalando scripts CLI y Plugin de Quickshell...\e[0m"
"$BASE_DIR/install.sh"

# 4. Verificación de Agente Host
echo -e "\n\e[1;34m[3/4] Verificando agente en el host...\e[0m"
if ! command -v /var/ossec/bin/wazuh-control >/dev/null 2>&1; then
  echo "  ℹ wazuh-agent no detectado en el host. Para instalarlo vía AUR:"
  echo "    paru -S wazuh-agent"
  echo "    sudo /var/ossec/bin/agent-auth -m 127.0.0.1 -A \"$(hostname)\""
  echo "    sudo systemctl enable --now wazuh-agent"
else
  sudo systemctl enable --now wazuh-agent 2>/dev/null || true
  echo "  ✓ wazuh-agent activo y corriendo."
fi

# 5. Resumen final
echo -e "\n\e[1;32m======================================================================\e[0m"
echo -e "\e[1;32m ✅ INSTALACIÓN Y CONFIGURACIÓN COMPLETADA CON ÉXITO                \e[0m"
echo -e "\e[1;32m======================================================================\e[0m"
echo -e " • \e[1mSOC Dashboard:\e[0m  https://localhost:$PORT"
echo -e " • \e[1mCredenciales:\e[0m   usuario admin, passwords en \e[1m$ENV_FILE\e[0m y \e[1m$CLI_CONFIG_FILE\e[0m (permisos 600)"
echo -e " • \e[1mStatus Bar:\e[0m     Icono de escudo en la barra superior de Omarchy."
echo -e " • \e[1mIA Incidentes:\e[0m  Respuesta automática ante alertas de severidad >= 10."
echo ""

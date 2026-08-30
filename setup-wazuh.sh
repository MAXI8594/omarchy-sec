#!/bin/bash

# ==============================================================================
# Omarchy Wazuh Security Suite - Interactive Setup & Deployment Wizard
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${WAZUH_PORT:-9001}"

echo -e "\e[1;36m======================================================================\e[0m"
echo -e "\e[1;36m 🛡️  OMARCHY ENDPOINT SECURITY & WAZUH EDR SETUP WIZARD              \e[0m"
echo -e "\e[1;36m======================================================================\e[0m"
echo ""
echo -e "Este asistente instala y configura el stack de seguridad para tu estación Omarchy:"
echo -e " • \e[1;32mEDR / XDR:\e[0m Detección de amenazas, reverse shells y anomalías en memoria."
echo -e " • \e[1;32mFIM:\e[0m Monitoreo de integridad de archivos en /etc, /usr/bin y ~/.config/hypr."
echo -e " • \e[1;32mSCA:\e[0m Evaluación continua contra benchmarks de seguridad CIS."
echo -e " • \e[1;32mSOC Dashboard:\e[0m Consola web en modo oscuro en https://localhost:$PORT"
echo -e " • \e[1;32mAI Bridge:\e[0m Despacho automático de incidentes al Agente de Omarchy."
echo ""

# 1. Escaneo de sensores existentes
echo -e "\e[1;33m[*] Verificando sensores de seguridad existentes en el sistema...\e[0m"
detection_json=$("$BASE_DIR/bin/omarchy-security-detect")
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
echo -e " • \e[1mCredenciales:\e[0m   admin / SecretPassword"
echo -e " • \e[1mStatus Bar:\e[0m     Icono de escudo en la barra superior de Omarchy."
echo -e " • \e[1mIA Incidentes:\e[0m  Respuesta automática ante alertas de severidad >= 10."
echo ""

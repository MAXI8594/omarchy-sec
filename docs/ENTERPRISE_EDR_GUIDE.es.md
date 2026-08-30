# 🏢 Guía Empresarial de Despliegue de EDR, XDR y MDR en Omarchy Linux

## Resumen Ejecutivo

En entornos corporativos modernos, los equipos de SOC (Security Operations Center) y proveedores de MDR (Managed Detection and Response) requieren visibilidad centralizada en tiempo real, auditoría continua y capacidad de contención remota sobre todas las estaciones de trabajo.

Dado que las estaciones de trabajo en **Omarchy Linux (Arch Linux + Hyprland)** utilizan una base "rolling-release", los vendors rara vez publican paquetes `.pkg.tar.zst` nativos. Esta guía documenta la ingeniería completa y validada para desplegar e integrar los principales agentes de seguridad corporativos (**CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex XDR y Wazuh**) en Omarchy, permitiendo que tu máquina reporte telemetría a la nube y sea visible en las consolas globales de tu empresa.

---

## 🏗️ Arquitectura de Telemetría y Gestión de Flota

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CONSOLAS CENTRALES EN LA NUBE                        │
│  (Falcon Cloud • Defender Security Portal • SentinelOne Console • SOC) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Stream de salida TLS/443 persistente)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   ESTACIÓN DE TRABAJO OMARCHY                          │
│                                                                        │
│  ┌───────────────────────┐              ┌───────────────────────────┐  │
│  │   AGENTE CORPORATIVO  │              │   OMARCHY SEC SENTINEL    │  │
│  │  (Falcon / MDE / S1)  │ <----------> │    (Widget Barra & Panel) │  │
│  │  Telemetría eBPF/LKM  │              │  Monitoreo en tiempo real │  │
│  └───────────┬───────────┘              └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │             RESPONDE AUTÓNOMO LOCAL CON AGENTE DE IA             │  │
│  │                  (`omarchy-sec agent` Bridge)                    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Estrategias de Instalación de Paquetes en Arch / Omarchy

Los departamentos de IT suelen entregar instaladores en formato `.deb` (Debian/Ubuntu) o `.rpm` (Red Hat/CentOS/SLES). En Arch/Omarchy se utilizan dos métodos principales:

### Método 1: Conversión con `debtap` (Paquetes `.deb`)
Convierte paquetes `.deb` en paquetes nativos de Arch (`.pkg.tar.zst`), integrándolos con el gestor de paquetes `pacman` y creando los servicios de systemd correspondientes.

```bash
paru -S --needed debtap
sudo debtap -u
debtap <paquete-instalador>.deb
sudo pacman -U <paquete-instalador>-1-x86_64.pkg.tar.zst
```

### Método 2: Extracción con `rpmextract` / `bsdtar` (Paquetes `.rpm`)
Extrae directamente los árboles de directorios (`/opt`, `/etc/systemd/system`) hacia la raíz del sistema conservando permisos.

```bash
paru -S --needed rpmextract
cd /
sudo rpmextract.sh /ruta/al/<paquete-instalador>.rpm
sudo systemctl daemon-reload
```

---

## 🛠️ Procedimientos de Despliegue por Plataforma

### 1. 🦅 CrowdStrike Falcon Sensor (`falcon-sensor`)
Monitoreo de comportamiento a nivel de kernel y grafo de amenazas.

* **Dependencias:** `linux-headers`, `libnl`, `openssl`.
* **Instalación:**
  ```bash
  cd /
  sudo rpmextract.sh falcon-sensor-<version>.amzn2.x86_64.rpm
  sudo systemctl daemon-reload
  ```
* **Onboarding y Registro con la Nube:**
  ```bash
  # Configurar el Customer ID (CID) de tu empresa
  sudo /opt/CrowdStrike/falconctl -s -f --cid="<CUSTOMER_ID_HEX>"
  
  # Forzar el modo eBPF en kernels modernos de Arch
  sudo /opt/CrowdStrike/falconctl -s --rfm-state=false
  
  # Habilitar e iniciar el servicio
  sudo systemctl enable --now falcon-sensor
  ```
* **Verificación:**
  ```bash
  sudo /opt/CrowdStrike/falconctl -g --cid --rfm-state --version
  ```

---

### 2. 🛡️ Microsoft Defender for Endpoint (`mdatp`)
Protección de endpoint integrada con el portal Microsoft 365 Defender.

* **Dependencias:** `audit`, `mde-netfilter` (o eBPF).
* **Instalación mediante `debtap`:**
  ```bash
  debtap -u
  debtap mdatp_*.deb
  sudo pacman -U mdatp-*.pkg.tar.zst
  ```
* **Onboarding Corporativo:**
  Ejecutar el script oficial provisto por tu departamento de IT:
  ```bash
  sudo python3 MicrosoftDefenderATPOnboardingLinuxClient.py
  ```
* **Verificación de Conectividad con la Nube:**
  ```bash
  mdatp health --field org_id
  mdatp health --field healthy
  mdatp connectivity test
  ```

---

### 3. 🟣 SentinelOne Singularity Linux Agent (`sentinelone`)
EDR autónomo con motor de comportamiento heurístico en tiempo real.

* **Instalación:**
  ```bash
  cd /
  sudo rpmextract.sh SentinelAgent-<version>.rpm
  sudo systemctl daemon-reload
  ```
* **Onboarding con el Site Token:**
  ```bash
  # Registrar el Site Token de la empresa
  sudo /opt/sentinelone/bin/sentinelctl control site-token set "<SITE_TOKEN>"
  
  # Habilitar e iniciar el servicio
  sudo systemctl enable --now sentinelone
  ```
* **Verificación de Estado:**
  ```bash
  sudo /opt/sentinelone/bin/sentinelctl status
  ```

---

### 4. 🔷 Palo Alto Networks Cortex XDR (`cortex-agent` / `traps`)
Prevención de exploits y analítica de seguridad en memoria.

* **Instalación:**
  Ejecutar el instalador corporativo `.sh`:
  ```bash
  sudo chmod +x cortex-installer.sh
  sudo ./cortex-installer.sh --distribution-token="<DISTRIBUTION_TOKEN>"
  ```
* **Verificación:**
  ```bash
  sudo /opt/traps/bin/cytool check
  sudo /opt/traps/bin/cytool enum
  ```

---

### 5. 🐺 Wazuh Agent (MDR y SIEM Agéntico On-Prem / Cloud)
Auditoría FIM, evaluación SCA contra CIS benchmarks y detección de CVEs.

* **Instalación:**
  ```bash
  paru -S --needed wazuh-agent
  ```
* **Registro con el Manager Central:**
  ```bash
  sudo /var/ossec/bin/agent-auth -m <IP_O_FQDN_MANAGER> -P "<REGISTRATION_PASSWORD>" -A "$(hostname)"
  sudo sed -i 's/<address>.*<\/address>/<address><IP_O_FQDN_MANAGER><\/address>/' /var/ossec/etc/ossec.conf
  sudo systemctl enable --now wazuh-agent
  ```

---

## 🔒 Microsegmentación y Red Zero Trust

Para garantizar que los equipos Omarchy reporten a la nube sin vulnerar la seguridad local:

1. **Salida Exclusiva (Egress Zero Trust):** Todos los agentes modernos se conectan únicamente hacia afuera (Outbound TLS/Port 443 vía HTTPS/gRPC/WebSockets) hacia las IPs y CDNs del fabricante.
2. **Entrada Bloqueada (Ingress Deny):** No es necesario abrir puertos de entrada en el workstation de Omarchy. La regla por defecto `ufw default deny incoming` se mantiene intacta.
3. **Coexistencia con Auditd:** En kernels Linux modernos con soporte eBPF (`CONFIG_BPF=y`), el agente no satura el subsistema de auditoría tradicional.

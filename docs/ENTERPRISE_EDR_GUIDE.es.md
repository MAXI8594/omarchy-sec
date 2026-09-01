# 🏢 Guía Empresarial de Despliegue de EDR, XDR y MDR en Omarchy Linux

## Resumen Ejecutivo

Los equipos de SOC y los proveedores de MDR necesitan visibilidad continua y
evidencia de cumplimiento sobre todos los endpoints corporativos, incluidas las
estaciones Linux que sus desarrolladores insisten en usar.

Los vendors rara vez publican paquetes `.pkg.tar.zst` nativos, así que meter un
sensor corporativo (**CrowdStrike Falcon, Microsoft Defender, SentinelOne,
Cortex XDR, Wazuh**) en una estación basada en Arch implica convertir o extraer
el formato de paquete de otra distribución.

> **Qué es esta guía y qué no.** Reúne los pasos de instalación y enrolamiento
> documentados por cada vendor, ordenados para Arch Linux. Los comandos son los
> mismos que `bin/omarchy-sec-onboard` ejecuta o imprime para cada vendor, así el
> asistente CLI y esta página no divergen. **No** están verificados por el CI de
> este repositorio: el pipeline no instala ningún sensor comercial, y los vendors
> cambian instaladores y flags entre versiones. Tomalo como punto de partida para
> contrastar contra la documentación vigente de tu vendor y tus términos de
> licencia, no como un blueprint validado.

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
│  │        RESPUESTA A INCIDENTES ASISTIDA POR IA (LOCAL)            │  │
│  │   (`omarchy-sec agent` — disparo automático, acción humana)      │  │
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

### 5. 🐺 Wazuh Agent (SIEM y MDR On-Prem / Cloud)
Auditoría FIM, evaluación SCA y detección de vulnerabilidades sobre el
inventario de paquetes.

* **Instalación:**
  ```bash
  paru -S --needed wazuh-agent
  ```
* **Registro con el Manager:**
  ```bash
  sudo /var/ossec/bin/agent-auth -m <IP_O_FQDN_MANAGER> -P "<REGISTRATION_PASSWORD>" -A "$(hostname)"
  sudo sed -i 's/<address>.*<\/address>/<address><IP_O_FQDN_MANAGER><\/address>/' /var/ossec/etc/ossec.conf
  sudo systemctl enable --now wazuh-agent
  ```
  Omití `-P` cuando el manager no exige password de registro. El stack
  single-node de este repositorio es uno de esos casos: su sección `auth` tiene
  `<use_password>no</use_password>`, y lo único que contiene el registro es que
  `:1515` está enlazado a `127.0.0.1`. `setup.sh` registra el host local con
  `agent-auth -m 127.0.0.1` en consecuencia. Si reenlazás ese puerto para
  alcanzar otros equipos, volvé a activar la password de registro.
* **Alcance de la integridad de archivos:** la config del manager de este
  repositorio vigila `/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin` y `/boot`.
  `$HOME` no está monitoreado por defecto — agregalo a la sección `syscheck` del
  agente si necesitás cobertura de manipulación de dotfiles.

---

## 🔒 Microsegmentación y Red Zero Trust

Para que la telemetría corporativa siga fluyendo sin ampliar la superficie de
ataque de la estación:

1. **Egress exclusivo (sensores cloud):** un sensor gestionado desde la nube
   mantiene una conexión saliente persistente hacia el backend de su fabricante
   y no necesita ningún puerto entrante. El default de Omarchy
   (`ufw default deny incoming`) se mantiene intacto.
2. **Listeners solo en loopback (stack local de Wazuh):** si desplegás el stack
   `docker/single-node/` en lugar de —o además de— un sensor cloud, ese stack
   **sí** escucha: seis puertos publicados (`1514`, `1515`, `514/udp`, `55000`,
   `9200`, `9001`), todos enlazados a `127.0.0.1`. Nada es alcanzable desde la
   red, pero están escuchando, y cualquier usuario local los alcanza. Ver
   [`ZERO_TRUST_MICROSEGMENTATION.es.md`](ZERO_TRUST_MICROSEGMENTATION.es.md)
   para la tabla completa y sus consecuencias.
3. **Coexistencia con Auditd:** en kernels modernos con soporte eBPF
   (`CONFIG_BPF=y`) el sensor puede evitar el subsistema de auditoría. Si tu EDR
   igual lo requiere, configurá `auditd` con `backlog_wait_time` para no
   estrangular el kernel.

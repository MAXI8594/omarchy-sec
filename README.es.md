<div align="center">

# 🛡️ Omarchy Sec
### Seguridad de Endpoint Universal (EDR/XDR/MDR) y Respuesta Autónoma a Incidentes con IA
**Diseñado nativamente para [Omarchy Linux](https://omarchy.org) (Arch Linux + Hyprland + Quickshell)**

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-matriz-de-sensores-edrxdr-corporativos)
[![DevSecOps Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-resultados-del-pipeline-de-calidad-devsecops)
[![Reporte: PDF](https://img.shields.io/badge/Informe-Descargar%20PDF-red.svg)](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[**🇺🇸 Read in English**](README.md) • [**🧩 Repo del Widget**](https://github.com/MAXI8594/omarchy-sec-plugin) • [**📄 Informe Ejecutivo en PDF**](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf) • [**📬 Propuestas de PR para Omarchy**](docs/OMARCHY_UPSTREAM_PR.es.md)

</div>

---

## 📦 Un Proyecto, Tres Entregables

Siguiendo la división sugerida por el mantenedor de Omarchy, Omarchy Sec se distribuye como tres piezas independientes, cada una por el canal que le corresponde:

| # | Entregable | Vive en | Se distribuye por | Estado |
| :-- | :--- | :--- | :--- | :--- |
| 1 | **Widget de barra en Quickshell** — el escudo en la barra y su panel de inspección | [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | [Omarchy Plugin Marketplace](https://plugins.omarchy.org/) → `omarchy plugin add` | Envío pendiente — ver [`docs/PUBLISHING.es.md`](docs/PUBLISHING.es.md) |
| 2 | **Propuestas de configuración del sistema** — `omarchy firewall`, hardening de SSH, hooks de EDR | [`docs/OMARCHY_UPSTREAM_PR.es.md`](docs/OMARCHY_UPSTREAM_PR.es.md) | Discusión de RFC / documentos de diseño en el Discord de Omarchy, canal `#omarchy-security` | Compartido para discusión |
| 3 | **CLI `omarchy-sec` + servicio watcher** — motor de detección, puente a la API de Wazuh, unit systemd de usuario | **este repositorio** | Paquete AUR → `paru -S omarchy-sec` | Empaquetado en curso |

> **El widget ya no vive en este repositorio.** Se extrajo para que el repo del plugin contenga únicamente QML, un manifiesto, un README y una licencia. El marketplace exige un repositorio público por plugin, y su escáner automático marca las capacidades `installer`, `service-management` y `package-manager` para revisión manual — que un script instalador y un unit de systemd en el mismo repo dispararían en cada release.

Las tres piezas son utilizables por separado, con una sola dependencia entre ellas: **el widget lee su estado del CLI `omarchy-sec`.** Sin el CLI instalado, el escudo se muestra en su estado *desconocido* atenuado en lugar de reportar una protección que nunca midió.

---

## 🧭 Centro Interactivo de Documentación

Explorá las especificaciones técnicas completas, diagramas arquitectónicos y guías paso a paso:

| Tema de Documentación | Descripción | Enlace Directo |
| :--- | :--- | :--- |
| 🏛️ **Arquitectura y Telemetría** | Especificación técnica completa de sondas eBPF, kernel y streaming al SOC. | [**`docs/ARCHITECTURE.md`**](docs/ARCHITECTURE.md) |
| 🎯 **Por qué Omarchy Necesita EDR** | Modelo de amenazas del desarrollador moderno (supply chain, dotfile tampering). | [**`docs/WHY_OMARCHY_NEEDS_EDR.es.md`**](docs/WHY_OMARCHY_NEEDS_EDR.es.md) |
| 📬 **Propuestas de PR para Omarchy (DHH)** | 3 propuestas concretas: `omarchy firewall`, SSH hardening y hooks de telemetría. | [**`docs/OMARCHY_UPSTREAM_PR.es.md`**](docs/OMARCHY_UPSTREAM_PR.es.md) |
| 🏢 **Guías de Despliegue EDR Empresarial** | Playbooks para **CrowdStrike, Microsoft Defender, SentinelOne, Cortex y Wazuh**. | [**`docs/ENTERPRISE_EDR_GUIDE.es.md`**](docs/ENTERPRISE_EDR_GUIDE.es.md) |
| 🔒 **Microsegmentación Zero Trust** | Endurecimiento de red, telemetría de salida TLS/443 y 0 puertos abiertos. | [**`docs/ZERO_TRUST_MICROSEGMENTATION.es.md`**](docs/ZERO_TRUST_MICROSEGMENTATION.es.md) |
| 🤖 **Respuesta con IA ("Call Agent")** | Conexión en tiempo real con la API REST de Wazuh (:55000) para triage y contención. | [**`docs/AUTONOMOUS_AI_INCIDENT_RESPONSE.es.md`**](docs/AUTONOMOUS_AI_INCIDENT_RESPONSE.es.md) |
| 🧪 **Pipeline de Calidad DevSecOps** | 6 controles automáticos Pre-PR (SAST, IaC, SCA, Escaneo de Secretos, DAST). | [**`docs/DEVSECOPS_PIPELINE.es.md`**](docs/DEVSECOPS_PIPELINE.es.md) |
| 🎯 **Matriz de Amenazas y MITRE** | Mapeo de vectores de ataque con la matriz MITRE ATT&CK. | [**`docs/THREAT_MODEL.md`**](docs/THREAT_MODEL.md) |
| 🧩 **Widget de Barra (repo aparte)** | El plugin de Quickshell: instalación, remoción, ajustes y estados. | [**`MAXI8594/omarchy-sec-plugin`**](https://github.com/MAXI8594/omarchy-sec-plugin) |
| 🚀 **Guía de Publicación en Marketplace** | Requisitos reales del marketplace, reglas del escaneo de seguridad y checklist de envío. | [**`docs/PUBLISHING.es.md`**](docs/PUBLISHING.es.md) |

---

## 🌟 Resumen Ejecutivo

**Omarchy Sec** resuelve la necesidad de seguridad corporativa sin ralentizar a los desarrolladores:

* 🏢 **Visibilidad de Flota Centralizada:** Permite que los equipos de SOC y proveedores de MDR (Azure Defender, Falcon Cloud, SentinelOne Management Console) monitoreen y protejan estaciones Omarchy.
* 🛡️ **Motor Agnóstico Multi-Sensor:** Detecta y unifica automáticamente telemetría de **CrowdStrike Falcon, Microsoft Defender (MDE), SentinelOne, Cortex XDR y Wazuh**.
* ⚡ **SOC Autohospedado en 1-Click (`./setup.sh`):** Despliega el stack completo de Wazuh XDR en Docker (en Modo Oscuro en `https://localhost:9001`) con enrolamiento automático del host.
* 📊 **Widget Adaptativo en la Barra:** Se distribuye por separado a través del [Omarchy Plugin Marketplace](https://plugins.omarchy.org/). Muestra `Omarchy Sec` por defecto y adapta dinámicamente su título y botones al seleccionar sensores; lee su estado del CLI `omarchy-sec`.
* 🤖 **Respuesta Autónoma a Incidentes con IA ("Call Agent"):** Conecta la API REST de Wazuh (:55000) e historial de alertas con el agente de IA para investigación y contención activa.
* 🔒 **Seguridad de Red Zero Trust:** Telemetría de salida exclusiva (Egress TLS/443) hacia las nubes SOC corporativas; cero puertos de entrada expuestos a la red — el stack Wazuh autoalojado sólo escucha en `127.0.0.1` (ver [`docker-compose.yml`](docker/single-node/docker-compose.yml)).
* 🧼 **100% Espacio de Usuario:** Cumple estrictamente con las directrices de Omarchy: jamás modifica `/usr/share/omarchy/`.

---

## 🏗️ Arquitectura del Sistema y Flujo de Telemetría

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
│  │             RESPUESTA AUTÓNOMA LOCAL CON AGENTE DE IA            │  │
│  │                  (`omarchy-sec agent` Bridge)                    │  │
│  │       API REST (:55000) • alerts.json • Sockets • Procesos       │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🏢 Matriz de Sensores EDR/XDR Corporativos

| Sensor / Fabricante | Tipo de Paquete | Método de Despliegue en Arch | Comando Rápido | Guía Detallada |
| :--- | :--- | :--- | :--- | :--- |
| **CrowdStrike Falcon** | `.rpm` (RHEL/SLES) | `rpmextract` + `falconctl --cid` (Modo eBPF) | `omarchy-sec onboard falcon` | [**Guía Falcon**](docs/ENTERPRISE_EDR_GUIDE.es.md#1--crowdstrike-falcon-sensor-falcon-sensor) |
| **Microsoft Defender (MDE)** | `.deb` (Ubuntu) | `debtap` + `OnboardingLinuxClient.py` | `omarchy-sec onboard defender` | [**Guía Defender**](docs/ENTERPRISE_EDR_GUIDE.es.md#2-️-microsoft-defender-for-endpoint-mdatp) |
| **SentinelOne Singularity** | `.rpm` / `.deb` | `rpmextract` + `sentinelctl site-token` | `omarchy-sec onboard sentinelone` | [**Guía SentinelOne**](docs/ENTERPRISE_EDR_GUIDE.es.md#3--sentinelone-singularity-linux-agent-sentinelone) |
| **Palo Alto Cortex XDR** | `.sh` Bundle | Script instalador + `--distribution-token` | `omarchy-sec onboard cortex` | [**Guía Cortex**](docs/ENTERPRISE_EDR_GUIDE.es.md#4--palo-alto-networks-cortex-xdr-cortex-agent--traps) |
| **Wazuh Open XDR/EDR** | AUR / Nativo | `paru -S wazuh-agent` + `agent-auth` | `omarchy-sec onboard wazuh` | [**Guía Wazuh**](docs/ENTERPRISE_EDR_GUIDE.es.md#5--wazuh-agent-mdr-y-siem-agéntico-on-prem--cloud) |

---

## 🤖 Respuesta Autónoma a Incidentes con IA ("Call Agent")

Al presionar **`[ 🤖 Call Agent ]`** en el panel o ejecutar `omarchy-sec agent`, el agente de IA de Omarchy recibe un volcado forense vivo desde la API REST de Wazuh (`:55000`):

```
┌────────────────────────────────────────────────────────┐
│               VOLCADO FORENSE EN VIVO                  │
├────────────────────────────────────────────────────────┤
│ 1. Estado del Endpoint en Wazuh (Agente 001, versión)  │
│ 2. Historial de Alertas de alerts.json con IDs MITRE   │
│ 3. Puertos y Sockets de Red en Escucha (ss -tuln)      │
│ 4. Árbol de Procesos y Consumo de Recursos (ps aux)    │
│ 5. Acceso a Herramientas CLI (omarchy-sec api, ufw)    │
└────────────────────────────────────────────────────────┘
```

---

## 🧪 Resultados del Pipeline de Calidad DevSecOps

```text
======================================================================
 🛡️  OMARCHY SEC: PRE-PR DEVSECOPS & QUALITY PIPELINE                 
======================================================================

[1/6] SAST: Shell Script Analysis (shellcheck)...
  ✓ PASS: ShellCheck: 0 issues found across all bash scripts
[2/6] SAST: Omarchy Plugin & QML Manifest Validation...
  ✓ PASS: Omarchy Plugin Validator: 0 schema or import errors
[3/6] Secrets Scanning (Gitleaks & TruffleHog)...
  ✓ PASS: Gitleaks: No leaked secrets, credentials, or private keys
[4/6] IaC & Misconfiguration Scanning (Trivy)...
  ✓ PASS: Trivy IaC: Docker compose definitions passed security audit
[5/6] Functional: Sensor Detection Engine Verification...
  ✓ PASS: Detection Engine: Functional (Wazuh EDR, Status: protected)
[6/6] DAST: SOC Dashboard Port Connectivity (https://localhost:9001)...
  ✓ PASS: DAST Health Check: Port 9001 responsive (HTTP 302)

======================================================================
 Test Results: 6 Passed | 0 Failed
======================================================================
 ✅ All Pre-PR Security & Quality Gates PASSED.
```

---

## 🚀 Inicio Rápido

### 1. Instalar el CLI `omarchy-sec` (AUR)

El CLI y su servicio watcher de usuario se empaquetan para el AUR. Una vez publicado el paquete:

```bash
paru -S omarchy-sec        # o: yay -S omarchy-sec
```

Después, habilitá el watcher en segundo plano para tu usuario:

```bash
systemctl --user enable --now omarchy-sec-watcher.service
```

> **El paquete AUR todavía se está preparando.** Hasta que esté publicado, instalá desde un checkout de git:
> ```bash
> git clone https://github.com/MAXI8594/omarchy-sec.git
> cd omarchy-sec
> ./install.sh
> ```
> `install.sh` escribe únicamente dentro de `~/.local/` y `~/.config/` — sin root, y jamás toca `/usr/share/omarchy/`, así que `omarchy update` no se ve afectado.

### 2. Instalar el widget de barra (Marketplace)

El widget vive en su propio repositorio y se instala con el CLI de plugins de Omarchy:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
```

Para removerlo:

```bash
omarchy plugin disable io.github.maxi8594.omarchy-sec
omarchy plugin remove  io.github.maxi8594.omarchy-sec
```

Instalá primero el paso 1: el widget es sólo una interfaz y muestra un escudo *desconocido* atenuado hasta que el CLI `omarchy-sec` esté presente para medir algo.

### 3. (Opcional) Desplegar el SOC Wazuh autohospedado

```bash
./setup.sh                 # asistente interactivo de despliegue de Wazuh XDR (Docker)
```

### Comandos del CLI `omarchy-sec`

Provistos por el paquete `omarchy-sec` del paso 1:

```bash
omarchy-sec status                   # Muestra estado de protección y sensores (JSON)
omarchy-sec onboard <vendor>         # Asistente interactivo de onboarding corporativo
omarchy-sec agent                    # Llama al Agente de Seguridad con telemetría en vivo
omarchy-sec api summary              # Consulta resumen en vivo de la API de Wazuh (:55000)
omarchy-sec api alerts 20 7          # Consulta últimas 20 alertas con severidad >= 7
omarchy-sec dashboard                # Abre el SOC Dashboard en el navegador (:9001)
omarchy-sec test                     # Ejecuta el pipeline completo de pruebas DevSecOps
```

---

<div align="center">

**[📄 Descargar Informe Ejecutivo en PDF](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)**

*Desarrollado con pasión para la comunidad de Omarchy por **Maximiliano Olivera** — [GitHub](https://github.com/MAXI8594) · [LinkedIn](https://www.linkedin.com/in/maximiliano-daniel-olivera/) · <maxioliverait@gmail.com>*

</div>

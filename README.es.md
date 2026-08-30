<div align="center">

# 🛡️ Omarchy Sec
### Seguridad de Endpoint Universal (EDR/XDR/MDR) y Respuesta Autónoma a Incidentes con IA
**Diseñado nativamente para [Omarchy Linux](https://omarchy.org) (Arch Linux + Hyprland + Quickshell)**

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-matriz-de-sensores-edrxdr-corporativos)
[![DevSecOps Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-resultados-del-pipeline-de-calidad-devsecops)
[![Reporte: PDF](https://img.shields.io/badge/Informe-Descargar%20PDF-red.svg)](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[**🇺🇸 Read in English**](README.md) • [**📄 Informe Ejecutivo en PDF**](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf) • [**📬 Propuestas de PR para Omarchy**](docs/OMARCHY_UPSTREAM_PR.es.md)

</div>

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
| 🚀 **Guía de Publicación en Marketplace** | Pasos para publicar en el Marketplace oficial de Omarchy. | [**`docs/PUBLISHING.es.md`**](docs/PUBLISHING.es.md) |

---

## 🌟 Resumen Ejecutivo

**Omarchy Sec** resuelve la necesidad de seguridad corporativa sin ralentizar a los desarrolladores:

* 🏢 **Visibilidad de Flota Centralizada:** Permite que los equipos de SOC y proveedores de MDR (Azure Defender, Falcon Cloud, SentinelOne Management Console) monitoreen y protejan estaciones Omarchy.
* 🛡️ **Motor Agnóstico Multi-Sensor:** Detecta y unifica automáticamente telemetría de **CrowdStrike Falcon, Microsoft Defender (MDE), SentinelOne, Cortex XDR y Wazuh**.
* ⚡ **SOC Autohospedado en 1-Click (`./setup.sh`):** Despliega el stack completo de Wazuh XDR en Docker (en Modo Oscuro en `https://localhost:9001`) con enrolamiento automático del host.
* 📊 **Widget Adaptativo en la Barra:** Muestra `Omarchy Sec` por defecto y adapta dinámicamente su título y botones al seleccionar sensores.
* 🤖 **Respuesta Autónoma a Incidentes con IA ("Call Agent"):** Conecta la API REST de Wazuh (:55000) e historial de alertas con el agente de IA para investigación y contención activa.
* 🔒 **Seguridad de Red Zero Trust:** Salida exclusiva (Egress TLS/443); cero puertos de entrada abiertos requeridos.
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

## 🚀 Inicio Rápido y Referencia de Comandos

### Instalación
```bash
# Clonar el repositorio
git clone https://github.com/MAXI8594/omarchy-sec.git
cd omarchy-sec

# Ejecutar el instalador en 1-click
./install.sh

# (Opcional) Desplegar el stack completo de Wazuh con el asistente interactivo
./setup.sh
```

### Comandos del CLI `omarchy-sec`
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

*Desarrollado con pasión para la comunidad de Omarchy por [Maximiliano Olivera (MAXI8594)](https://github.com/MAXI8594).*

</div>

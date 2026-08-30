# 🛡️ Omarchy Sec (Suite Universal de Seguridad y Respuesta con IA)

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-guías-de-despliegue-corporativo-edrxdr)
[![Security Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-pipeline-de-calidad-y-seguridad-pre-pr)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Plataforma empresarial de **Seguridad de Endpoint Agnóstica** con **Respuesta Autónoma a Incidentes con IA** y un **Widget Nativo para la Barra Superior de Omarchy (Quickshell QML)** diseñado para **Omarchy Linux (Arch Linux + Hyprland)**.

---

## 🌟 Características Principales

* 🏢 **Gestión de Flota Empresarial:** Despliegue e integración de agentes corporativos (**CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex XDR, Wazuh**) para visibilidad total desde el SOC central en la nube.
* 🛡️ **Soporte EDR/XDR Agnóstico:** Detección automática y agregación de telemetría de todos los sensores de seguridad en Linux.
* ⚡ **Asistente 1-Click (`./setup.sh`):** Despliega el stack completo de Wazuh XDR en Docker (Modo Oscuro en `https://localhost:9001`) y enrola el agente local con un comando.
* 📊 **Widget Adaptativo en la Barra:** Muestra `Omarchy Sec` por defecto y adapta dinámicamente su título y botones al seleccionar sensores.
* 🤖 **Respuesta con IA y "Call Agent":** Análisis forense en tiempo real con acceso directo a la API REST de Wazuh (`:55000`) e historial de alertas.
* 🔒 **Microsegmentación Zero Trust:** Telemetría saliente exclusiva (Egress TLS/443); 0 puertos de entrada abiertos requeridos.
* 🧪 **Verificado con DevSecOps:** Pasó el 100% de los controles Pre-PR (**SAST, IaC, Escaneo de Secretos, SCA y DAST**).

---

## 🏢 Guías de Despliegue Corporativo EDR / XDR

Para consultar la guía detallada de conversión de paquetes e integración corporativa en Arch / Omarchy:

👉 [**Guía Empresarial de Despliegue EDR (`docs/ENTERPRISE_EDR_GUIDE.es.md`)**](docs/ENTERPRISE_EDR_GUIDE.es.md)  
👉 [**Enterprise EDR Deployment Guide in English (`docs/ENTERPRISE_EDR_GUIDE.md`)**](docs/ENTERPRISE_EDR_GUIDE.md)

| Vendor / Sensor | Tipo de Paquete | Método de Onboarding | Comando CLI |
| :--- | :--- | :--- | :--- |
| **CrowdStrike Falcon** | `.rpm` (RHEL/SLES) | `rpmextract` + `falconctl --cid` | `omarchy-sec onboard falcon` |
| **Microsoft Defender (MDE)** | `.deb` (Ubuntu) | `debtap` + `OnboardingLinuxClient.py` | `omarchy-sec onboard defender` |
| **SentinelOne Singularity** | `.rpm` / `.deb` | `rpmextract` + `sentinelctl site-token` | `omarchy-sec onboard sentinelone` |
| **Palo Alto Cortex XDR** | `.sh` bundle | `./cortex-installer.sh --distribution-token` | `omarchy-sec onboard cortex` |
| **Wazuh Agent** | AUR / Nativo | `paru -S wazuh-agent` + `agent-auth` | `omarchy-sec onboard wazuh` |

---

## 🚀 Comandos del CLI `omarchy-sec`

```bash
# Ver estado de protección y sensores detectados
omarchy-sec status

# Asistente interactivo de onboarding corporativo
omarchy-sec onboard [falcon|defender|sentinelone|cortex|wazuh]

# Llamar al Agente de Seguridad con acceso a la API en vivo
omarchy-sec agent

# Consultar directamente la API de Wazuh
omarchy-sec api summary
omarchy-sec api alerts 20 7

# Abrir la consola web del SOC
omarchy-sec dashboard

# Ejecutar el pipeline de pruebas DevSecOps
omarchy-sec test
```

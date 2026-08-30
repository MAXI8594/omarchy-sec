# 🛡️ Omarchy Sec (EDR/XDR Agnóstico y Respuesta con IA)

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-soporte-agnóstico-de-sensores-edrxdr)
[![Security Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-pipeline-de-calidad-y-seguridad-pre-pr)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Plataforma empresarial de **Seguridad de Endpoint Agnóstica** con **Respuesta Autónoma a Incidentes con IA** y un **Widget Nativo para la Barra Superior de Omarchy (Quickshell QML)** diseñado para **Omarchy Linux (Arch Linux + Hyprland)**.

---

## 🌟 Características Principales

* 🛡️ **Soporte EDR/XDR Agnóstico:** Detecta, monitorea y agrega telemetría en tiempo real de **Wazuh**, **CrowdStrike Falcon**, **Palo Alto Cortex XDR**, **SentinelOne**, **Microsoft Defender (MDE)**, **Falco eBPF** y **Linux Auditd**.
* ⚡ **Asistente de Despliegue de Wazuh en 1-Click (`./setup-wazuh.sh`):** Si no hay un sensor corporativo instalado, despliega el stack completo de Wazuh XDR en Docker (con Modo Oscuro en `https://localhost:9001`) y enrola el agente del host con un solo comando.
* 📊 **Widget Nativo en la Barra de Omarchy:** Muestra el estado de protección en vivo (🟢 Protegido, 🟡 Advertencia, 🔴 Desprotegido) con un panel desplegable interactivo.
* 🤖 **Respuesta Autónoma a Incidentes con IA (`omarchy agent`):** Ante alertas críticas (Nivel >= 10), abre automáticamente una terminal flotante interactiva con telemetría forense para análisis y contención instantánea (con fallback de modelos: Claude, Gemini, Codex, OpenCode).
* 🔒 **Verificado con DevSecOps:** Pasó el 100% de los controles de calidad previos a PR (**SAST, IaC, Escaneo de Secretos, SCA y DAST**).
* 🧼 **100% Espacio de Usuario:** Cumple estrictamente con los estándares de Omarchy: jamás modifica `/usr/share/omarchy/`.

---

## 🔍 Soporte Agnóstico de Sensores EDR/XDR

El motor de detección inteligente (`bin/omarchy-sec-detect`) identifica las capas de seguridad activas:

| Sensor de Seguridad | Proceso / Servicio | Telemetría Aportada |
| :--- | :--- | :--- |
| **Wazuh Open XDR/EDR** | `wazuh-agent.service` + SOC Docker | FIM, SCA (CIS benchmarks), escáner CVE, matriz MITRE ATT&CK |
| **CrowdStrike Falcon** | `falcon-sensor.service` | EDR a nivel de kernel, Threat Graph |
| **Palo Alto Cortex XDR** | `cortex-agent.service` / `traps_pmd` | Prevención de exploits, protección de memoria |
| **SentinelOne** | `sentinelone.service` | Agente autónomo con IA de endpoint |
| **Microsoft Defender (MDE)** | `mdatp.service` | Protección y telemetría de Microsoft Defender |
| **Falco / Tetragon (eBPF)** | `falco.service` / `tetragon.service` | Seguridad en tiempo de ejecución basada en eBPF |
| **Linux Auditd** | `auditd.service` | Registro nativo de syscalls del kernel de Linux |

---

## 🚀 Instalación Rápida

```bash
# Asistente interactivo con despliegue de Wazuh y detección de sensores
./setup-wazuh.sh
```

---

## 🧪 Pipeline de Calidad y Seguridad Pre-PR

Ejecutá la suite completa de pruebas antes de publicar o enviar un PR:

```bash
./tests/run_tests.sh
```

**Resultado:**
* ✅ **SAST (ShellCheck & Semgrep):** 0 errores de sintaxis o malas prácticas.
* ✅ **Validación Omarchy:** 0 errores de esquema en el manifiesto y QML.
* ✅ **Escaneo de Secretos (Gitleaks & TruffleHog):** 0 credenciales o llaves filtradas.
* ✅ **IaC (Trivy):** 0 configuraciones inseguras en Docker.
* ✅ **DAST:** Endpoint de consola (`https://localhost:9001`) respondiendo con éxito.

---

## 📚 Documentación Completa

* 🇺🇸 **English Documentation:** [`README.md`](README.md)
* 🇪🇸 **Documentación en Español:** [`README.es.md`](README.es.md)
* 🚀 **Guía de Publicación en Marketplace:** [`docs/PUBLISHING.es.md`](docs/PUBLISHING.es.md)
* 📬 **Propuesta de PR para Omarchy (DHH):** [`docs/OMARCHY_UPSTREAM_PR.es.md`](docs/OMARCHY_UPSTREAM_PR.es.md)
* 🏗️ **Arquitectura Técnica:** [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
* 🎯 **Modelado de Amenazas MITRE:** [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md)

# 🛡️ Omarchy Sec (Universal Endpoint Security & Autonomous AI Responder)

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-agnostic-edrxdr-sensor-support)
[![Security Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-pre-pr-security--quality-pipeline)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An enterprise-grade, **Agnostic Endpoint Security Platform** and **Autonomous AI Incident Responder** with a native **Quickshell Top Bar Widget** designed specifically for **Omarchy Linux (Arch Linux + Hyprland)**.

---

## 🌟 Key Highlights

* 🏢 **Enterprise Fleet Management:** Seamlessly deploy and onboard corporate EDR/XDR/MDR sensors (**CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex XDR, Wazuh**) to enable full central SOC visibility.
* 🛡️ **Agnostic EDR/XDR Detection:** Auto-detects and aggregates telemetry from all installed Linux security engines.
* ⚡ **1-Click Wazuh Deployment Wizard (`./setup.sh`):** Deploy a self-hosted Wazuh XDR in Docker (with Dark Mode on `https://localhost:9001`) and enroll the host in one command.
* 📊 **Adaptive Quickshell Top Bar Widget:** Displays `Omarchy Sec` by default and dynamically adapts its title and actions when selecting specific sensors.
* 🤖 **Autonomous AI Incident Responder & "Call Agent":** Instant AI-driven incident investigation and containment with live REST API data access to Wazuh.
* 🔒 **Zero Trust Network Architecture:** Egress-only TLS/443 telemetry streaming; zero open inbound ports required on workstations.
* 🧪 **DevSecOps Verified:** Passed 100% of Pre-PR security quality gates (**SAST, IaC, Secrets scanning, SCA, and DAST**).

---

## 🏢 Enterprise EDR/XDR Deployment Playbooks

For comprehensive, step-by-step instructions on deploying commercial EDR agents on Arch Linux / Omarchy:

👉 [**English: Enterprise EDR Deployment Guide (`docs/ENTERPRISE_EDR_GUIDE.md`)**](docs/ENTERPRISE_EDR_GUIDE.md)  
👉 [**Español: Guía Empresarial de Despliegue EDR (`docs/ENTERPRISE_EDR_GUIDE.es.md`)**](docs/ENTERPRISE_EDR_GUIDE.es.md)

| Vendor / Sensor | Package Type | Onboarding Method | Command |
| :--- | :--- | :--- | :--- |
| **CrowdStrike Falcon** | `.rpm` (RHEL/SLES) | `rpmextract` + `falconctl --cid` | `omarchy-sec onboard falcon` |
| **Microsoft Defender (MDE)** | `.deb` (Ubuntu) | `debtap` + `OnboardingLinuxClient.py` | `omarchy-sec onboard defender` |
| **SentinelOne Singularity** | `.rpm` / `.deb` | `rpmextract` + `sentinelctl site-token` | `omarchy-sec onboard sentinelone` |
| **Palo Alto Cortex XDR** | `.sh` bundle | `./cortex-installer.sh --distribution-token` | `omarchy-sec onboard cortex` |
| **Wazuh Agent** | AUR / Native | `paru -S wazuh-agent` + `agent-auth` | `omarchy-sec onboard wazuh` |

---

## 🚀 CLI Commands

```bash
# Check protection status and detected sensors
omarchy-sec status

# Interactive enterprise onboarding wizard
omarchy-sec onboard [falcon|defender|sentinelone|cortex|wazuh]

# Call AI SOC Analyst Agent with live telemetry
omarchy-sec agent

# Query Wazuh REST API directly
omarchy-sec api summary
omarchy-sec api alerts 20 7

# Open local SOC dashboard
omarchy-sec dashboard

# Run pre-PR security and quality tests
omarchy-sec test
```

---

## 🧪 Pre-PR Security & Quality Pipeline

```bash
./tests/run_tests.sh
```

Passed 6/6 tests: **SAST (ShellCheck), Omarchy QML Validator, Gitleaks, Trivy IaC, Sensor Detection, and DAST (Port 9001 Health Check)**.

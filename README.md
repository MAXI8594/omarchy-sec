# 🛡️ Omarchy Sec (Agnostic EDR/XDR & Autonomous AI Responder)

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-agnostic-edrxdr-sensor-support)
[![Security Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-pre-pr-security--quality-pipeline)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An enterprise-grade, **Agnostic Endpoint Security Platform** and **Autonomous AI Incident Responder** with a native **Quickshell Top Bar Widget** designed specifically for **Omarchy Linux (Arch Linux + Hyprland)**.

---

## 🌟 Key Highlights

* 🛡️ **Agnostic EDR/XDR Support:** Seamlessly detects, monitors, and aggregates telemetry from **Wazuh**, **CrowdStrike Falcon**, **Palo Alto Cortex XDR**, **SentinelOne**, **Microsoft Defender (MDE)**, **Falco eBPF**, and **Linux Auditd**.
* ⚡ **1-Click Wazuh Deployment Wizard (`./setup-wazuh.sh`):** If no enterprise sensor is detected, deploy a self-hosted, full-stack Wazuh XDR in Docker (with Dark Mode on `https://localhost:9001`) and enroll the host in one command.
* 📊 **Native Omarchy Bar Widget:** Quickshell QML widget displaying active protection status (🟢 Protected, 🟡 Warning, 🔴 Unprotected) and a comprehensive popout details surface.
* 🤖 **Autonomous AI Incident Responder (`omarchy agent` Bridge):** Critical alerts (Level >= 10, such as reverse shells, memory injection, dotfile tampering) trigger an interactive floating terminal pre-loaded with forensic telemetry for instant analysis, triage, and containment.
* 🔒 **DevSecOps Verified:** Passed 100% of Pre-PR security quality gates (**SAST, IaC, Secrets scanning, SCA, and DAST**).
* 🧼 **100% User-Space:** Complies strictly with Omarchy design principles—never touches `/usr/share/omarchy/`, ensuring safe updates via `omarchy update`.

---

## 🔍 Agnostic EDR/XDR Sensor Support

The suite includes an intelligent detection engine (`bin/omarchy-sec-detect`) that monitors active protection layers:

| Security Sensor | Backend Process / Service | Telemetry Provided |
| :--- | :--- | :--- |
| **Wazuh Open XDR/EDR** | `wazuh-agent.service` + Docker SOC | FIM, SCA (CIS benchmarks), CVE vulnerability scanner, MITRE ATT&CK |
| **CrowdStrike Falcon** | `falcon-sensor.service` | Kernel-level behavioral EDR, Threat Graph telemetry |
| **Palo Alto Cortex XDR** | `cortex-agent.service` / `traps_pmd` | Behavioral threat protection, Exploit prevention |
| **SentinelOne** | `sentinelone.service` | Autonomous AI-driven endpoint agent |
| **Microsoft Defender (MDE)** | `mdatp.service` | Cloud-delivered endpoint protection & AV |
| **Falco / Tetragon (eBPF)** | `falco.service` / `tetragon.service` | Kernel eBPF runtime security & syscall inspection |
| **Linux Auditd** | `auditd.service` | Native Linux kernel audit logging |

---

## 🏗️ Architecture Overview

```
                      ┌──────────────────────────────────────────────┐
                      │    SECURITY STATUS & MULTI-SENSOR ENGINE     │
                      │       (`bin/omarchy-sec-detect`)        │
                      └──────────────────────┬───────────────────────┘
                                             │
                                             ▼
┌───────────────────────────┐       ┌────────────────────────────────┐
│   DETECTED EDR SENSORS    │       │     OMARCHY STATUS WIDGET      │
│  Wazuh • Falcon • Cortex  │ ----> │    (Quickshell QML Top Bar)    │
│   Defender • Falco • S1   │       │   [  🟢 CrowdStrike / Wazuh ] │
└─────────────┬─────────────┘       └────────────────────────────────┘
              │
              ▼ (Security Alert / Incident Stream)
┌───────────────────────────┐
│   OMARCHY ALERT WATCHER   │
│ (systemd User Background) │
└─────────────┬─────────────┘
              │ (Critical Threat: Level >= 10)
              ▼
┌────────────────────────────────────────────────────────────────────┐
│              AUTONOMOUS AI INCIDENT RESPONDER                      │
│             (`bin/omarchy-sec-incident`)                      │
│   Floating Terminal • Multi-Agent Fallback (claude/gemini/codex)   │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. Interactive Setup Wizard (Deploys Wazuh or detects existing EDR)
```bash
./setup-wazuh.sh
```

### 2. Manual Installation
```bash
./install.sh
```

---

## 🧪 Pre-PR Security & Quality Pipeline

Before submitting code or proposing upstream PRs, run the comprehensive quality gate:

```bash
./tests/run_tests.sh
```

### Pipeline Results:
```text
======================================================================
 🛡️  OMARCHY SECURITY SUITE: PRE-PR DEVSECOPS & QUALITY PIPELINE      
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

## 🤝 Documentation & Marketplace Submission

* 🇺🇸 **English Documentation:** [`README.md`](README.md)
* 🇪🇸 **Documentación en Español:** [`README.es.md`](README.es.md)
* 🚀 **Marketplace Publishing Guide:** [`docs/PUBLISHING.md`](docs/PUBLISHING.md)
* 📬 **Upstream PR Proposal for Omarchy / DHH:** [`docs/OMARCHY_UPSTREAM_PR.md`](docs/OMARCHY_UPSTREAM_PR.md)
* 🏗️ **Technical Architecture:** [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
* 🎯 **Threat Model & MITRE Mapping:** [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md)

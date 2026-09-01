<div align="center">

# 🛡️ Omarchy Sec
### Universal Endpoint Security (EDR/XDR/MDR) & Autonomous AI Incident Responder
**Engineered natively for [Omarchy Linux](https://omarchy.org) (Arch Linux + Hyprland + Quickshell)**

[![Omarchy Compatible](https://img.shields.io/badge/Omarchy-4.0+-purple.svg)](https://omarchy.org)
[![Agnostic EDR](https://img.shields.io/badge/EDR-Wazuh%20|%20Falcon%20|%20Cortex%20|%20Defender%20|%20eBPF-blue.svg)](#-enterprise-edrxdr-sensor-matrix)
[![DevSecOps Pipeline](https://img.shields.io/badge/DevSecOps-SAST%20|%20IaC%20|%20Secrets%20|%20DAST%20Passed-success.svg)](#-devsecops-quality-pipeline-results)
[![Report: PDF](https://img.shields.io/badge/Report-Download%20PDF-red.svg)](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[**🇪🇸 Leer en Español**](README.es.md) • [**🧩 Bar Widget Repo**](https://github.com/MAXI8594/omarchy-sec-plugin) • [**📄 Executive PDF Report**](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf) • [**📬 Upstream PR Proposals**](docs/OMARCHY_UPSTREAM_PR.md)

</div>

---

## 📦 One Project, Three Deliverables

Following the split suggested by the Omarchy maintainer, Omarchy Sec ships as three independent pieces, each through the channel that fits it:

| # | Deliverable | Lives in | Distributed via | Status |
| :-- | :--- | :--- | :--- | :--- |
| 1 | **Quickshell bar widget** — the shield in the bar and its inspection panel | [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | [Omarchy Plugin Marketplace](https://plugins.omarchy.org/) → `omarchy plugin add` | Submission pending — see [`docs/PUBLISHING.md`](docs/PUBLISHING.md) |
| 2 | **System config proposals** — `omarchy firewall`, SSH hardening, EDR hooks | [`docs/OMARCHY_UPSTREAM_PR.md`](docs/OMARCHY_UPSTREAM_PR.md) | RFC / design doc discussion in the Omarchy Discord, channel `#omarchy-security` | Shared for discussion |
| 3 | **`omarchy-sec` CLI + watcher service** — detection engine, Wazuh API bridge, systemd user unit | **this repository** | AUR package → `paru -S omarchy-sec` | Packaging in progress |

> **The widget no longer lives in this repository.** It was extracted so that the plugin repo contains nothing but QML, a manifest, a README and a license. The marketplace requires one public repository per plugin, and its automated scanner flags the `installer`, `service-management` and `package-manager` capabilities for manual review — which an installer script and a systemd unit sitting in the same repo would trigger on every release.

The three pieces are independently usable, with one dependency between them: **the widget reads its state from the `omarchy-sec` CLI.** Without the CLI installed, the shield renders in its muted *unknown* state rather than reporting a protection status it never measured.

---

## 🧭 Interactive Documentation Hub

Explore the complete technical specifications, architectural blueprints, and vendor playbooks:

| Documentation Topic | Description | Link |
| :--- | :--- | :--- |
| 🏛️ **Architecture & Telemetry** | Complete technical specification of Linux kernel probes, eBPF, and SOC streaming. | [**`docs/ARCHITECTURE.md`**](docs/ARCHITECTURE.md) |
| 🎯 **Why Omarchy Needs EDR** | The modern developer workstation threat model (supply chain, dotfile tampering). | [**`docs/WHY_OMARCHY_NEEDS_EDR.md`**](docs/WHY_OMARCHY_NEEDS_EDR.md) |
| 📄 **RFC / Proposal (Markdown)** | The full proposal as a reviewable document — three separately arguable proposals plus the real DevSecOps pipeline. | [**`docs/PROPOSAL.md`**](docs/PROPOSAL.md) |
| 💬 **Discord post** | The same RFC cut into paste-ready `#omarchy-security` messages, each under Discord's 2000-char cap. | [**`docs/DISCORD_POST.md`**](docs/DISCORD_POST.md) |
| 📬 **Upstream PR Proposals (DHH)** | Concrete proposals for `omarchy firewall`, SSH hardening, and EDR agent hooks. | [**`docs/OMARCHY_UPSTREAM_PR.md`**](docs/OMARCHY_UPSTREAM_PR.md) |
| 🏢 **Enterprise EDR Playbooks** | Step-by-step corporate guides for **CrowdStrike, Defender, SentinelOne, Cortex, Wazuh**. | [**`docs/ENTERPRISE_EDR_GUIDE.md`**](docs/ENTERPRISE_EDR_GUIDE.md) |
| 🔒 **Zero Trust Microsegmentation** | Network hardening, outbound TLS/443 telemetry, and zero open inbound ports. | [**`docs/ZERO_TRUST_MICROSEGMENTATION.md`**](docs/ZERO_TRUST_MICROSEGMENTATION.md) |
| 🤖 **Autonomous AI Responder** | How the "Call Agent" connects to the Wazuh REST API (:55000) for forensic triage. | [**`docs/AUTONOMOUS_AI_INCIDENT_RESPONSE.md`**](docs/AUTONOMOUS_AI_INCIDENT_RESPONSE.md) |
| 🧪 **DevSecOps Quality Gate** | 6 automated pre-PR quality checks (SAST, IaC, SCA, Secrets scanning, DAST). | [**`docs/DEVSECOPS_PIPELINE.md`**](docs/DEVSECOPS_PIPELINE.md) |
| 🎯 **Threat Matrix & MITRE** | MITRE ATT&CK mapping for developer Linux endpoints. | [**`docs/THREAT_MODEL.md`**](docs/THREAT_MODEL.md) |
| 🧩 **Bar Widget (separate repo)** | The Quickshell plugin itself: install/removal steps, settings and states. | [**`MAXI8594/omarchy-sec-plugin`**](https://github.com/MAXI8594/omarchy-sec-plugin) |
| 🚀 **Marketplace Submission** | The real marketplace requirements, security scan rules and submission checklist. | [**`docs/PUBLISHING.md`**](docs/PUBLISHING.md) |

---

## 🌟 Executive Summary

**Omarchy Sec** bridges the gap between high-velocity developer workstations and corporate enterprise compliance:

* 🏢 **Central SOC Fleet Visibility:** Enables corporate SOCs and MDR providers (Azure Defender, Falcon Cloud, SentinelOne Management Console) to monitor and protect Omarchy workstations seamlessly.
* 🛡️ **Agnostic Multi-Sensor Engine:** Auto-detects and aggregates telemetry from **CrowdStrike Falcon, Microsoft Defender (MDE), SentinelOne, Cortex XDR, and Wazuh**.
* ⚡ **1-Click Self-Hosted SOC (`./setup.sh`):** Deploys a full-stack Wazuh XDR in Docker (in Dark Mode on `https://localhost:9001`) with host agent enrollment.
* 📊 **Adaptive Quickshell Bar Widget:** Distributed separately through the [Omarchy Plugin Marketplace](https://plugins.omarchy.org/). Displays `Omarchy Sec` by default and dynamically adapts its title and action buttons when inspecting specific sensors; it reads its state from the `omarchy-sec` CLI.
* 🤖 **Autonomous AI Incident Responder ("Call Agent"):** Bridges live SIEM/EDR REST API data to the AI coding agent for instant forensic triage and defensive containment.
* 🔒 **Zero Trust Network Security:** Egress-only TLS/443 telemetry to corporate SOC clouds; zero inbound ports exposed to the network — the self-hosted Wazuh SOC stack binds exclusively to `127.0.0.1` (see [`docker-compose.yml`](docker/single-node/docker-compose.yml)).
* 🧼 **100% User-Space:** Strictly adheres to Omarchy rules—never touches `/usr/share/omarchy/`, ensuring safe updates via `omarchy update`.

---

## 🏗️ System Architecture & Fleet Telemetry

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CORPORATE SOC CLOUD CONSOLES                         │
│  (Falcon Cloud • Defender Security Portal • SentinelOne Console • SOC) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Outbound Persistent TLS/443 Stream)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   OMARCHY ENTERPRISE WORKSTATIONS                      │
│                                                                        │
│  ┌───────────────────────┐              ┌───────────────────────────┐  │
│  │   CORPORATE SENSOR    │              │   OMARCHY SEC SENTINEL    │  │
│  │  (Falcon / MDE / S1)  │ <----------> │    (Bar Widget & Panel)   │  │
│  │  eBPF Kernel Probes   │              │  Dynamic Health Status    │  │
│  └───────────┬───────────┘              └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │             AUTONOMOUS LOCAL AI INCIDENT RESPONDER               │  │
│  │                  (`omarchy-sec agent` Bridge)                    │  │
│  │       Wazuh REST API (:55000) • alerts.json • Sockets • PIDs     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🏢 Enterprise EDR/XDR Sensor Matrix

| Security Sensor | Package Type | Deployment Strategy on Arch | Quick CLI Command | Playbook Guide |
| :--- | :--- | :--- | :--- | :--- |
| **CrowdStrike Falcon** | `.rpm` (RHEL/SLES) | `rpmextract` + `falconctl --cid` (eBPF mode) | `omarchy-sec onboard falcon` | [**Falcon Guide**](docs/ENTERPRISE_EDR_GUIDE.md#1--crowdstrike-falcon-sensor-falcon-sensor) |
| **Microsoft Defender (MDE)** | `.deb` (Ubuntu) | `debtap` + `OnboardingLinuxClient.py` | `omarchy-sec onboard defender` | [**Defender Guide**](docs/ENTERPRISE_EDR_GUIDE.md#2-️-microsoft-defender-for-endpoint-mdatp) |
| **SentinelOne Singularity** | `.rpm` / `.deb` | `rpmextract` + `sentinelctl site-token` | `omarchy-sec onboard sentinelone` | [**SentinelOne Guide**](docs/ENTERPRISE_EDR_GUIDE.md#3--sentinelone-singularity-linux-agent-sentinelone) |
| **Palo Alto Cortex XDR** | `.sh` Bundle | Installer script + `--distribution-token` | `omarchy-sec onboard cortex` | [**Cortex Guide**](docs/ENTERPRISE_EDR_GUIDE.md#4--palo-alto-networks-cortex-xdr-cortex-agent--traps) |
| **Wazuh Open XDR/EDR** | AUR / Native | `paru -S wazuh-agent` + `agent-auth` | `omarchy-sec onboard wazuh` | [**Wazuh Guide**](docs/ENTERPRISE_EDR_GUIDE.md#5--wazuh-agent-open-source--managed-soc) |

---

## 🤖 Autonomous AI Incident Response ("Call Agent")

When you click **`[ 🤖 Call Agent ]`** in the top bar panel or run `omarchy-sec agent`, the AI coding agent receives a live forensic dump directly from the Wazuh REST API (`:55000`):

```
┌────────────────────────────────────────────────────────┐
│               LIVE FORENSIC INJECTION                  │
├────────────────────────────────────────────────────────┤
│ 1. Wazuh Agent 001 Health Status & Group Metadata      │
│ 2. Recent Alert History from alerts.json with MITRE IDs│
│ 3. Active Listening Network Sockets (ss -tuln)         │
│ 4. Resource-Heavy & Newly Spawned Processes (ps aux)   │
│ 5. CLI Tool Access (omarchy-sec api, ufw, kill, btrfs) │
└────────────────────────────────────────────────────────┘
```

The AI can immediately differentiate false positives, kill unauthorized reverse shells, isolate attacking IPs, and restore files from snapshots.

---

## 🧪 DevSecOps Quality Pipeline Results

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

## 🚀 Quickstart

### 1. Install the `omarchy-sec` CLI (AUR)

The CLI and its user-level watcher service are packaged for the AUR. Once the package is published:

```bash
paru -S omarchy-sec        # or: yay -S omarchy-sec
```

Then enable the background watcher for your user:

```bash
systemctl --user enable --now omarchy-sec-watcher.service
```

> **The AUR package is still being prepared.** Until it lands, install from a git checkout:
> ```bash
> git clone https://github.com/MAXI8594/omarchy-sec.git
> cd omarchy-sec
> ./install.sh
> ```
> `install.sh` writes only inside `~/.local/` and `~/.config/` — no root, and it never touches `/usr/share/omarchy/`, so `omarchy update` is unaffected.

### 2. Install the bar widget (Marketplace)

The widget lives in its own repository and installs through the Omarchy plugin CLI:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
```

To remove it:

```bash
omarchy plugin disable io.github.maxi8594.omarchy-sec
omarchy plugin remove  io.github.maxi8594.omarchy-sec
```

Install step 1 first: the widget is a thin front end and shows a muted *unknown* shield until the `omarchy-sec` CLI is present to measure anything.

### 3. (Optional) Deploy the self-hosted Wazuh SOC

```bash
./setup.sh                 # interactive Wazuh XDR deployment wizard (Docker)
```

### CLI Command Reference

Provided by the `omarchy-sec` package from step 1:

```bash
omarchy-sec status                   # Inspect protection status & active sensors (JSON)
omarchy-sec onboard <vendor>         # Interactive enterprise EDR onboarding wizard
omarchy-sec agent                    # Call AI SOC Analyst Agent with live telemetry
omarchy-sec api summary              # Query Wazuh REST API live summary (:55000)
omarchy-sec api alerts 20 7          # Query last 20 alerts with severity >= 7
omarchy-sec dashboard                # Open local SOC dashboard in browser (:9001)
omarchy-sec test                     # Run the automated 6-tier DevSecOps test suite
```

---

<div align="center">

**[📄 Download the Executive PDF Report](docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)**

*Developed with passion for the Omarchy community by **Maximiliano Olivera** — [GitHub](https://github.com/MAXI8594) · [LinkedIn](https://www.linkedin.com/in/maximiliano-daniel-olivera/) · <maxioliverait@gmail.com>*

</div>

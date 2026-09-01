# 🛡️ Omarchy Sec Wiki

Welcome to the **Omarchy Sec** knowledge base and technical documentation portal.

**Omarchy Sec** is an enterprise-grade, agnostic Endpoint Security (EDR/XDR) suite and Autonomous AI Incident Response platform built natively for **Omarchy Linux (Arch Linux + Hyprland + Quickshell)**.

---

## 🧭 Wiki Table of Contents

* 🏛️ **[Architecture & Fundamentals](Architecture-and-Fundamentals)**  
  Technical breakdown of Linux kernel telemetry, eBPF probes, Wazuh REST API integration, and Quickshell status routing.
* 🎯 **[Why Omarchy Needs EDR](Why-Omarchy-Needs-EDR)**  
  The security reality of modern developer workstations: supply chain attacks, dotfile tampering, and enterprise compliance.
* 📬 **[Upstream PR Proposals for Omarchy (DHH)](Upstream-PR-Proposals)**  
  Concrete, low-overhead proposals to incorporate firewall management, SSH hardening, and EDR telemetry into core Omarchy.
* 🏢 **[Enterprise EDR & MDR Playbooks](Enterprise-EDR-Playbooks)**  
  Step-by-step guides for deploying CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex XDR, and Wazuh on Arch/Omarchy.
* 🔒 **[Zero Trust Microsegmentation](Zero-Trust-Microsegmentation)**  
  Network hardening, outbound-only TLS/443 telemetry, and eliminating inbound attack vectors.
* 🤖 **[Autonomous AI Incident Response ("Call Agent")](Autonomous-AI-Incident-Response)**  
  Bridging live SIEM/EDR data directly to the coding agent for automated forensic investigation and threat containment.
* 🧪 **[DevSecOps Quality & Security Pipeline](DevSecOps-Quality-Pipeline)**  
  The 6 pre-PR quality gates: SAST, IaC, SCA, Secrets scanning, and DAST.

---

## 📦 Three Deliverables, Three Channels

Omarchy Sec is split into three independent pieces, each distributed through the channel that fits it:

| Deliverable | Lives in | Distributed via |
| :--- | :--- | :--- |
| Quickshell bar widget | [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | [Omarchy Plugin Marketplace](https://plugins.omarchy.org/) — `omarchy plugin add` |
| System config proposals | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) → `docs/OMARCHY_UPSTREAM_PR.md` | RFC discussion in the Omarchy Discord, `#omarchy-security` |
| `omarchy-sec` CLI + watcher service | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) | AUR package — `paru -S omarchy-sec` |

The widget reads its state from the `omarchy-sec` CLI, so install the AUR package for the bar indicator to report anything.

---

## ⚡ Quick Navigation & Resources

* 💻 **CLI & Service Repository:** [MAXI8594/omarchy-sec](https://github.com/MAXI8594/omarchy-sec)
* 🧩 **Bar Widget Repository:** [MAXI8594/omarchy-sec-plugin](https://github.com/MAXI8594/omarchy-sec-plugin)
* 📄 **Executive PDF Report:** [`docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf`](https://github.com/MAXI8594/omarchy-sec/blob/main/docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)
* 🚀 **Marketplace Submission Guide:** [`docs/PUBLISHING.md`](https://github.com/MAXI8594/omarchy-sec/blob/main/docs/PUBLISHING.md)

# 🛡️ Omarchy Sec Wiki

Welcome to the **Omarchy Sec** knowledge base and technical documentation portal.

**Omarchy Sec** is a vendor-agnostic endpoint security integration for **Omarchy Linux (Arch Linux + Hyprland + Quickshell)**: a detection engine that reports which EDR sensor is active, a Wazuh REST client, a single-node Wazuh stack in Docker, a Quickshell bar widget, and a watcher that opens your coding agent with incident context when a high-severity alert fires.

It is a personal open-source project. It has had no external security audit, and the pages below say what the code does rather than what the category usually promises.

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
  Network hardening, outbound-only telemetry for cloud sensors, and the loopback-only port layout of the local Wazuh stack.
* 🤖 **[AI-Assisted Incident Response ("Call Agent")](Autonomous-AI-Incident-Response)**  
  Bridging live SIEM/EDR data into the coding agent. The trigger is automatic; the containment is yours.
* 🧪 **[DevSecOps Quality & Security Pipeline](DevSecOps-Quality-Pipeline)**  
  What the local 6-check suite and the 4-step CI workflow actually run — ShellCheck, Gitleaks, Semgrep, Trivy IaC, and two functional checks — and what they miss (there is no SCA).

---

## 📦 Three Deliverables, Three Channels

Omarchy Sec is split into three independent pieces, each distributed through the channel that fits it:

| Deliverable | Lives in | Distributed via |
| :--- | :--- | :--- |
| Quickshell bar widget | [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | [Omarchy Plugin Marketplace](https://plugins.omarchy.org/) — `omarchy plugin add` |
| System config proposals | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) → `docs/OMARCHY_UPSTREAM_PR.md` | RFC discussion in the Omarchy Discord, `#omarchy-security` |
| `omarchy-sec` CLI + watcher service | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) | AUR package — `paru -S omarchy-sec` *(packaging in progress)* |

The widget reads its state from the `omarchy-sec` CLI, so install the AUR package for the bar indicator to report anything.

---

## ⚡ Quick Navigation & Resources

* 💻 **CLI & Service Repository:** [MAXI8594/omarchy-sec](https://github.com/MAXI8594/omarchy-sec)
* 🧩 **Bar Widget Repository:** [MAXI8594/omarchy-sec-plugin](https://github.com/MAXI8594/omarchy-sec-plugin)
* 📄 **Executive PDF Report:** [`docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf`](https://github.com/MAXI8594/omarchy-sec/blob/main/docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf)
* 🚀 **Marketplace Submission Guide:** [`docs/PUBLISHING.md`](https://github.com/MAXI8594/omarchy-sec/blob/main/docs/PUBLISHING.md)

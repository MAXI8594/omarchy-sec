# 🎯 Why Omarchy Needs EDR: The Modern Workstation Threat Model

## The Security Reality of Developer Workstations

Developer workstations are the **highest-value targets** in technology companies. Unlike general office endpoints, a developer's machine holds:
1. **Production & Cloud Access:** High-privilege SSH keys, AWS/GCP/Azure credentials, production Kubernetes tokens, and VPN tunnels.
2. **Untrusted Code Execution:** Daily execution of `npm install`, `pip install`, `cargo build`, `gem install`, and pulling arbitrary third-party Docker images with post-install hooks.
3. **Local Elevated Privileges:** Access to `sudo` and critical configuration files.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        DEVELOPER THREAT VECTORS                        │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Malicious Package Scripts (npm/pip typosquatting, dependency poison)│
│ 2. Reverse Shell Spawning from test containers or dev APIs             │
│ 3. Dotfile & Shell Hijacking (~/.config/hypr, ~/.bashrc, ~/.ssh)       │
│ 4. Unauthorized Privilege Escalation (Sudo abuse, setuid exploits)     │
│ 5. Ransomware / Unauthorized Mass File Encryption                      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Why Basic Firewalls Are Not Enough

Omarchy Linux enables UFW with an inbound deny policy by default (`ufw default deny incoming`). While this blocks unsolicited external inbound connections, it **does not protect against:**
* Outbound reverse shells initiated by a malicious dependency.
* Unnoticed modifications to system binary checksums or PAM configurations.
* In-memory process injections or hijacked background daemons.

## The Solution: Native EDR + AI-Assisted Response

Integrating an EDR like **Wazuh, CrowdStrike, or Microsoft Defender** with **Omarchy Sec** narrows the gap. What that buys you, stated at the level the code supports:

* **Continuous telemetry:** process, package, port and file-integrity data collected by the sensor. With the bundled Wazuh stack, `syscollector` inventories hardware, OS, network, packages, ports and processes hourly, and `syscheck` hashes the system directories it is configured to watch.
* **Detection, on the collector's own schedule — not instantly.** Some signals are event-driven; others are polled. In the shipped manager config, for example, the listening-port snapshot (`netstat`) and the login history (`last`) run every 360 seconds, and FIM scans every 12 hours. Expect minutes, not milliseconds, for those.
* **AI-assisted triage:** at alert level ≥ 10 the local coding agent (`omarchy-sec agent`) opens with live telemetry preloaded, so a developer without security expertise gets a starting point instead of a raw log. It proposes containment and can run `kill` or `ufw` in that terminal with you present — see [`AUTONOMOUS_AI_INCIDENT_RESPONSE.md`](AUTONOMOUS_AI_INCIDENT_RESPONSE.md). Nothing is contained automatically, and file rollback is not wired up.

> **Caveat worth knowing before you rely on this:** the bundled manager config monitors system paths (`/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`) for file integrity. `$HOME` — and therefore `~/.config/hypr`, `~/.bashrc` and `~/.ssh`, vector 3 above — is **not** covered out of the box. Add those paths to the agent's `syscheck` stanza if that vector is the one you care about.

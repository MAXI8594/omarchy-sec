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

## The Solution: Native EDR + Autonomous AI Response

Integrating an EDR like **Wazuh, CrowdStrike, or Microsoft Defender** with **Omarchy Sec** bridges the gap:
* **Continuous Behavioral Telemetry:** Real-time visibility into process trees, syscalls, and file integrity.
* **Instant Detection:** Immediate alarms on abnormal socket bindings or unexpected `/tmp` execution.
* **AI-Assisted Containment:** Gives the local AI coding agent (`omarchy-sec agent`) live telemetry to isolate threats and rollback files without requiring deep security expertise from the developer.

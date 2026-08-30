# 🎯 Why Omarchy Needs EDR: The Modern Threat Model

## The Security Reality of Developer Workstations

Developer workstations are the **highest-value target** in tech companies. A developer workstation possesses:
1. **Production Access:** SSH keys, AWS/GCP credentials, VPN tunnels, and deployment tokens.
2. **Third-Party Code Execution:** Running `npm install`, `pip install`, `cargo build`, or pulling Docker images that execute arbitrary pre-install and build scripts.
3. **Local Tooling Privileges:** Access to `sudo` and system configuration files.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        DEVELOPER THREAT VECTORS                        │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Malicious Package Scripts (npm/pip typosquatting, dependency poison)│
│ 2. Reverse Shell Spawning from test containers or dev APIs             │
│ 3. Dotfile & Shell Hijacking (~/.config/hypr, ~/.bashrc, ~/.ssh)       │
│ 4. Unauthorized Privilege Escalation (Sudo abuse, setuid exploits)     │
│ 5. Ransomware / Unauthorized File Encryption                           │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Why Basic Firewalls Are Not Enough

Omarchy enables UFW with an inbound deny policy by default (`ufw default deny incoming`). While this blocks unsolicited external connections, it **does not protect against:**
* Outbound reverse shells initiated by a malicious package.
* Unnoticed modifications to system binary checksums.
* In-memory process injections or hijacked developer daemons.

## The Solution: Native EDR + AI Response

Integrating an EDR like **Wazuh, CrowdStrike, or Microsoft Defender** with **Omarchy Sec** bridges the gap:
* **Continuous Monitoring:** Real-time visibility into process trees, syscalls, and file integrity.
* **Instant Detection:** Alarms on abnormal socket bindings or unexpected `/tmp` execution.
* **AI-Assisted Containment:** Gives the AI coding agent immediate context to isolate threats and rollback files without requiring deep security expertise from the developer.

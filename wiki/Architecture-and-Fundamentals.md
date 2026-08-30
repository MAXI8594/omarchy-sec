# 🏛️ Architecture & Fundamentals

## System Topology & Telemetry Layers

The **Omarchy Sec** architecture connects the low-level Linux kernel and file subsystem directly to the developer's desktop and autonomous AI coding agents:

```
[Linux Kernel / Syscalls / File Integrity Changes]
                        │
                        ▼
       [Endpoint EDR Layer (eBPF / Agent)]
   (Wazuh • CrowdStrike • Defender • Cortex • S1)
                        │
                        ├─────────────────────────────────────────────────┐
                        │ (Outbound TLS/443 Telemetry)                    │ (Local Stream)
                        ▼                                                 ▼
          [Corporate SOC Cloud Console]                       [omarchy-sec-watcher]
      (Azure Defender / Falcon Cloud / SOC)                (systemd User Background)
                                                                          │
                                                ┌─────────────────────────┴─────────────────────────┐
                                                ▼                                                   ▼
                                       [Quickshell Top Bar]                                [High Severity Alert]
                                    [  🟢 Omarchy Sec ]                                  (Level >= 10 Threat)
                                                │                                                   │
                                                ▼ (Click / Summon)                                  ▼
                                        [Interactive Panel]                               [Floating AI Terminal]
                                   (Dynamic Multi-Sensor View)                         (Pre-Loaded SOC Telemetry)
```

---

## Technical Foundations

### 1. eBPF vs. Legacy Kernel Modules (LKM)
Traditional security agents relied on compiling Loadable Kernel Modules (LKMs) against exact kernel headers via DKMS. On rolling-release systems like Arch Linux, kernel upgrades frequently broke sensor compatibility.

**Omarchy Sec** leverages modern **eBPF (Extended Berkeley Packet Filter)** execution (`CONFIG_BPF=y`, `CONFIG_BPF_SYSCALL=y`). This allows security probes to run in kernel space safely and sandbox-isolated, fully decoupled from kernel minor version bumps.

### 2. Multi-Sensor Aggregation (`bin/omarchy-sec-detect`)
The detection engine scans systemd units, processes, and binary installations to detect the active security profile:
* If Wazuh is active, it connects to the local SOC stack and polls `alerts.json`.
* If an enterprise sensor (CrowdStrike, Defender, Cortex, SentinelOne) is running, it extracts health and engine status.
* If multiple sensors are active, it provides multi-layer health telemetry.

### 3. Wazuh REST API Client (`bin/omarchy-sec-wazuh-api`)
Connects to `https://localhost:55000` with JWT token management, exposing:
* `summary`: Agent count, version, and latest real alerts.
* `alerts`: Structured event stream with MITRE technique mappings.
* `sca`: CIS benchmark compliance audits.
* `fim`: File Integrity Monitoring changes on `/etc`, `/usr/bin`, and `~/.config/hypr`.

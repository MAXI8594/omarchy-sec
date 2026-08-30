# Architecture & Technical Specification

## System Topology

The **Omarchy Wazuh Security Suite** bridges four core layers:

1. **Endpoint Agent Layer:** Runs directly on the Arch Linux host (`wazuh-agent.service`), collecting kernel events, auditd telemetry, FIM checksums, and package inventories.
2. **SOC Core & Analytics Layer:** Encapsulated in Docker (`docker/single-node`), composed of Wazuh Manager, Indexer (OpenSearch), and Dashboard on port `9001` with TLS encryption and Dark Mode enabled.
3. **UI Integration Layer (Quickshell):** Native desktop plugin mounted in Omarchy's top status bar (`~/.config/omarchy/plugins/io.github.maxi8594.omarchy-wazuh/`), providing real-time visual health checks and popout management.
4. **Autonomous AI Responder Layer:** A persistent systemd user daemon (`omarchy-wazuh-watcher`) monitoring structured alerts in real time, triggering `omarchy-security-incident` to launch the AI coding agent in a floating Alacritty terminal when high-severity threats are detected.

---

## Event Flow Lifecycle

```
[System Event / Syscall / File Change]
                 │
                 ▼
[Wazuh Agent (Host: /var/ossec)]
                 │ Encrypted TLS Stream (:1514)
                 ▼
[Wazuh Manager (Docker: single-node-wazuh.manager-1)]
                 │ Correlates against 3,000+ detection rules & MITRE Matrix
                 ├─────────────────────────────┬─────────────────────────────┐
                 ▼                             ▼                             ▼
        [OpenSearch Indexer]          [Wazuh Dashboard :9001]     [alerts.json Live Log]
        (Search & Analytics)          (SOC Web Console)                      │
                                                                             ▼
                                                                [omarchy-wazuh-watcher]
                                                                (systemd User Service)
                                                                             │
                                              ┌──────────────────────────────┴──────────────────────────────┐
                                              ▼                                                             ▼
                                     [Alert Level 7-9 (Medium)]                                    [Alert Level >= 10 (Critical)]
                                              │                                                             │
                                     [Desktop Notification]                                        [Desktop Notification +
                                     (notify-send in Omarchy)                                      Autonomous AI Responder]
                                                                                                            │
                                                                                                   [omarchy-launch-terminal]
                                                                                                   (Floating Alacritty Window
                                                                                                    running omarchy-agent)
```

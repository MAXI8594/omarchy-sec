# 🤖 Autonomous AI Incident Response ("Call Agent")

## Transforming Static Alerts into Actionable Defense

Traditional security panels display static warning icons that require a dedicated security engineer to inspect logs. **Omarchy Sec** bridges the EDR engine directly to the **Omarchy AI Coding Agent** (`claude`, `gemini`, `codex`, `agy`).

```
[Security Anomaly Detected] ➔ [Wazuh API Query (:55000)] ➔ [Pre-Loaded Telemetry] ➔ [AI Terminal Opens]
```

### What the AI Agent Receives:
1. **Endpoint Health Summary:** OS, architecture, active agent count, connection state.
2. **Recent Real Alerts:** Structured alerts from `alerts.json` (severity, rule ID, MITRE tactic, target file/IP).
3. **Live System Sockets:** Output of `ss -tuln` showing unexpected listening services.
4. **Process Tree:** Output of `ps aux` highlighting high-resource or recently spawned PIDs.

### Actions the AI Agent Can Take:
* **Threat Triage:** Differentiate between developer test activity (false positives) and genuine threats.
* **Process Termination:** Kill malicious processes via PID or process name.
* **Network Isolation:** Temporarily block compromised IPs via `ufw`.
* **File Rollback:** Offer rollback of tampered files using Btrfs / Snapper snapshots.

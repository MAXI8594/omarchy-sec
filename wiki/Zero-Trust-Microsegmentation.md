# 🔒 Zero Trust Microsegmentation Architecture

## Network Hardening Principles

To maintain strict network microsegmentation on developer workstations while ensuring continuous corporate SOC telemetry:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   ZERO TRUST NETWORK ARCHITECTURE                      │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Ingress Strict Deny (ufw default deny incoming)                     │
│    No listening ports are opened on the workstation.                   │
│                                                                        │
│ 2. Egress-Only Encrypted Stream (Outbound TLS/Port 443)                │
│    Persistent WebSocket / gRPC / HTTPS connection to vendor cloud.     │
│                                                                        │
│ 3. Kernel eBPF Probing (CONFIG_BPF=y)                                  │
│    Decoupled from auditd to prevent buffer overflows or dropouts.      │
└────────────────────────────────────────────────────────────────────────┘
```

### Microsegmentation Rules:
* **No Inbound Holes:** EDR sensors operate entirely via push/pull over persistent outbound streams.
* **Encrypted Telemetry:** All syscalls, process trees, and FIM hashes are transmitted using TLS 1.3 encryption.
* **Container Isolation:** Docker containers running local SIEM/SOC components (Wazuh) are restricted to local loopback (`127.0.0.1:9001`, `127.0.0.1:55000`).

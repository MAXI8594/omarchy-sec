# Architecture & Technical Specification

## System Topology

**Omarchy Sec** bridges four layers:

1. **Endpoint Agent Layer:** `wazuh-agent.service` on the Arch Linux host. What
   it collects is governed by the agent's own `/var/ossec/etc/ossec.conf`, which
   this repository does not ship — `setup.sh` only enrolls the agent against the
   local manager. The manager configuration in
   `docker/single-node/config/wazuh_cluster/wazuh_manager.conf` enables FIM
   (`syscheck` over `/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`),
   inventory collection (`syscollector`: hardware, OS, network, packages, ports,
   processes), rootcheck, SCA, and vulnerability detection against the collected
   package inventory.
2. **SOC Core & Analytics Layer:** Docker (`docker/single-node`) — Wazuh Manager,
   Indexer (OpenSearch), and Dashboard. The dashboard serves HTTPS
   (`server.ssl.enabled: true`) with dark mode on
   (`uiSettings.overrides.theme:darkMode: true`), published on
   `127.0.0.1:9001` only. Every published port in the stack is bound to
   loopback — see [`ZERO_TRUST_MICROSEGMENTATION.md`](ZERO_TRUST_MICROSEGMENTATION.md).
3. **UI Integration Layer (Quickshell):** Bar widget from the separate
   [`omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin)
   repository, installed by `install.sh` via `omarchy plugin add` into
   `~/.config/omarchy/plugins/io.github.maxi8594.omarchy-sec/`. It polls
   `omarchy-sec-detect` on a configurable interval (default 30s) and renders
   sensor status; it reports "unknown" rather than "unprotected" when the CLI is
   missing.
4. **AI Responder Layer:** `omarchy-sec-watcher`, a systemd *user* service,
   tails the manager's `alerts.json` through `docker exec`. At level ≥ 7 it
   raises a desktop notification; at level ≥ 10 it additionally runs
   `omarchy-sec-agent`, which assembles telemetry into a prompt and opens
   `omarchy-agent` in a terminal via `omarchy-launch-terminal`. **The trigger is
   automatic; the response is not** — the agent session is interactive and the
   user is present. Nothing is killed, blocked, or rolled back without them.

---

## Event Flow Lifecycle

```
[System Event / Syscall / File Change]
                 │
                 ▼
[Wazuh Agent (Host: /var/ossec)]
                 │ Wazuh "secure" encrypted agent channel (:1514/tcp, loopback)
                 ▼
[Wazuh Manager (Docker: single-node-wazuh.manager-1)]
                 │ Correlates against Wazuh's default upstream ruleset
                 │ (no custom rules are shipped in this repository)
                 ├─────────────────────────────┬─────────────────────────────┐
                 ▼                             ▼                             ▼
        [OpenSearch Indexer]          [Wazuh Dashboard :9001]     [alerts.json Live Log]
        (Search & Analytics)          (SOC Web Console)                      │
                                                                             ▼
                                                                [omarchy-sec-watcher]
                                                                (systemd User Service)
                                                                             │
                                              ┌──────────────────────────────┴──────────────────────────────┐
                                              ▼                                                             ▼
                                     [Alert Level 7-9 (Medium)]                                    [Alert Level >= 10 (Critical)]
                                              │                                                             │
                                     [Desktop Notification]                                        [Desktop Notification +
                                     (notify-send in Omarchy)                                       omarchy-sec-agent]
                                                                                                            │
                                                                                                   [omarchy-launch-terminal]
                                                                                                   (interactive omarchy-agent
                                                                                                    session, user present)
```

Thresholds are `MIN_NOTIFY_LEVEL` (default 7) and `MIN_AGENT_LEVEL` (default 10)
in `bin/omarchy-sec-watcher`; both are environment-overridable.

### Notes on the transport

The agent-to-manager channel on `:1514` uses Wazuh's own encrypted protocol
(`<connection>secure</connection>`), not TLS. TLS is used between the manager,
the indexer, and the dashboard (`FILEBEAT_SSL_VERIFICATION_MODE=full`, mutual
certificates under `config/wazuh_indexer_ssl_certs/`), and by the dashboard's
HTTPS listener. The indexer's HTTP layer is configured for **TLS 1.2**
(`plugins.security.ssl.http.enabled_protocols: ["TLSv1.2"]`).

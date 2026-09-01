# 🤖 AI-Assisted Incident Response ("Call Agent")

## What is and is not automatic

Traditional security panels show a static warning icon and leave you to go read
logs. **Omarchy Sec** instead opens your coding agent (`omarchy-agent`) with the
incident context already loaded.

Be clear about the boundary, because "autonomous" oversells it:

* **Automatic:** the trigger. `omarchy-sec-watcher` tails the manager's
  `alerts.json`; at level ≥ 7 it fires a desktop notification, and at level ≥ 10
  it also launches `omarchy-sec-agent`, which opens a terminal with the prompt
  preloaded.
* **Not automatic:** everything after that. The agent session is interactive and
  you are sitting in front of it. No process is killed, no IP is blocked, and no
  file is restored without you. The Wazuh `<active-response>` block that could
  do that automatically is commented out in `wazuh_manager.conf`.

```
[Alert level >= 10 in alerts.json] ➔ [Wazuh API query (:55000) + host telemetry]
                                   ➔ [Prompt assembled] ➔ [Interactive agent terminal]
```

## What the prompt actually contains

Verbatim from `bin/omarchy-sec-agent`:

1. **Hostname, ISO-8601 timestamp, and the primary active sensor** (`.primary`
   from `omarchy-sec-detect`).
2. **The triggering alert**, when invoked by the watcher: level, rule ID,
   description, source IP, affected file path.
3. **Wazuh agent summary** — `omarchy-sec-wazuh-api summary`, i.e. the `/agents`
   endpoint's affected items.
4. **The last 8 alerts** from `alerts.json`, projected to level, rule ID,
   description, timestamp, source IP and file path. *No MITRE technique field is
   included* — the projection does not extract one.
5. **Listening sockets** — the first 12 lines of `ss -tuln`.
6. **Top processes** — the first 8 lines of `ps aux --sort=-%cpu`. This is a
   CPU-ranked list, not a process tree.

## What the agent is told it can do

The prompt hands the agent a tool list and a mission, nothing more:

* `omarchy-sec-wazuh-api alerts [limit] [min_level]` — more alert history
* `omarchy-sec-wazuh-api sca` — Security Configuration Assessment results
* `omarchy-sec-wazuh-api fim` — file integrity changes
* `omarchy-sec-wazuh-api query <endpoint>` — any REST endpoint
* Shell tools: `ps`, `lsof`, `journalctl`, `ss`, `kill`, `ufw`

Its mission is to triage the alert, decide false positive vs. real, and
**propose or execute** containment in that terminal — process termination via
`kill`, IP blocking via `ufw`. Those are the agent's own actions in your shell,
with your permission, subject to your sudo password.

**Btrfs / Snapper rollback is not part of this.** Earlier versions of this page
listed file rollback as an agent capability; the prompt never mentions snapshots
and nothing in the project performs one. Recovering a tampered file is a manual
step you take yourself.

## Fallback

If `omarchy-agent` fails (quota exhaustion is the common case), the terminal
stays open and prints the alternatives to run by hand (`agy --prompt`,
`gemini --yolo`). It does not silently do nothing.

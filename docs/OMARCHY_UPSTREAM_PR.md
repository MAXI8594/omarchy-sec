# Upstream Pull Request Proposal: Enhanced Security & EDR Telemetry for Omarchy

## Summary

This proposal outlines three targeted enhancements to strengthen Omarchy's security posture while maintaining its signature opinionated, frictionless developer experience:

1. **New CLI Group: `omarchy firewall`** — A user-friendly, declarative interface for managing UFW firewall rules directly from the `omarchy` CLI.
2. **SSHD Hardening by Default** — Enforcing key-only authentication (`PasswordAuthentication no`, `MaxAuthTries 3`) when configuring OpenSSH via `omarchy setup security sshd`.
3. **EDR Telemetry & Security Incident Bridge** — An optional `omarchy setup security edr` recipe and Quickshell status widget to monitor endpoint integrity and dispatch security incidents to the default coding agent.

---

## 1. Feature: `omarchy firewall` CLI Group

### Problem
Omarchy enables UFW by default with a secure inbound deny policy, but currently lacks intuitive CLI commands for developers to inspect or open ports (e.g., local test servers, dev API ports, or database listeners). Users must fall back to raw `ufw` or `iptables` commands.

### Proposed Solution
Introduce `omarchy firewall` with the following subcommands:

```bash
omarchy firewall status                     # Pretty-printed active ports & rules
omarchy firewall allow <port> [--proto=tcp] # Allow a port with automatic comment
omarchy firewall deny <port>                # Revoke access to a port
omarchy firewall reset                      # Restore Omarchy default policy (deny in, allow out)
```

---

## 2. Feature: SSHD Hardening (`omarchy setup security sshd`)

### Problem
When `omarchy setup security sshd` fetches and authorizes public keys from GitHub, the underlying OpenSSH daemon configuration may still permit password authentication on LAN or Tailscale interfaces, leaving endpoints vulnerable to password-spraying or brute-force attempts.

### Proposed Solution
Add a hardened drop-in configuration at `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf`:

```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
```

---

## 3. Feature: EDR Telemetry & AI Incident Response

### Problem
Modern developer workstations frequently execute untrusted code (npm dependencies, pip packages, docker containers). Currently, Omarchy offers post-crash diagnostics (`omarchy agent crash`), but lacks proactive runtime detection for suspicious process activity (e.g., unauthorized reverse shells, `/tmp` executable execution, or tampering with `~/.config/hypr/`).

### Proposed Solution
Integrate an optional EDR watcher and Quickshell bar widget:
* **Real-time Alert Watcher:** A lightweight user daemon monitoring security events.
* **Autonomous Incident Responder:** High-severity events automatically launch a floating terminal running `omarchy-agent --prompt "..."` with pre-populated incident telemetry for immediate triage and containment.
* **Bar Widget:** A discrete shield widget in Quickshell displaying protection status.

---

## Compatibility & Safety
* **100% User-Space:** Implemented via user configurations and Quickshell plugins.
* **Zero Breaking Changes:** Maintains full backward compatibility with existing Omarchy installations and update paths.

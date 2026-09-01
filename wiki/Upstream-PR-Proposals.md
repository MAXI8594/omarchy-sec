# 📬 Upstream PR Proposals for Omarchy & DHH

> **Status: proposals, not implemented.** None of this has been submitted to or
> accepted by upstream Omarchy, and no code for these three items exists in the
> `omarchy-sec` repository. They are sketches meant to start a discussion.

Three concrete, targeted changes we would like to discuss with the upstream
Omarchy maintainers:

---

## 1. Proposal 1: `omarchy firewall` CLI Command Group

### Rationale
Developers frequently need to open local ports for test servers (e.g., Rails, Node, Next.js, Postgres) without remembering raw iptables or ufw syntax.

### Implementation
Add `/usr/share/omarchy/bin/omarchy-firewall` with subcommands:
* `omarchy firewall status`: Clean, colorized view of listening ports and active rules.
* `omarchy firewall allow <port> [--proto=tcp]`: Safely allows inbound port with an automatic comment.
* `omarchy firewall deny <port>`: Revokes access.
* `omarchy firewall reset`: Restores Omarchy default baseline policy.

---

## 2. Proposal 2: Default SSHD Hardening (`omarchy setup security sshd`)

### Rationale
When developers import SSH public keys via GitHub (`omarchy setup security sshd`), the underlying OpenSSH daemon might still allow password authentication on LAN or Tailscale networks.

### Implementation
Add a hardened drop-in configuration file at `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf`:
```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
```

---

## 3. Proposal 3: Native Incident Bridge for `omarchy-agent`

### Rationale
Omarchy already provides crash diagnostics (`omarchy agent crash <pid>`). We can expand `omarchy-agent` with a security incident skill:
* When a high-severity security anomaly is detected (Level >= 10), Omarchy launches the coding agent with pre-populated incident telemetry, so the AI can investigate the root cause and propose containment in a terminal the user is sitting in front of. The trigger is automatic; the containment is not, and deliberately so.

---

## Risk, per proposal

| Proposal | Scope | Risk |
| :--- | :--- | :--- |
| 1. `omarchy firewall` | CLI wrapper over `ufw`, which already requires `sudo`. No state of its own. | Low. Backwards compatible. |
| 2. SSHD hardening | **Not user-space** — writes `/etc/ssh/sshd_config.d/` and reloads `sshd`. | **Changes a security default and can lock you out** of SSH if no working public key is installed first. Needs a pre-flight key check, an explicit prompt, and a documented rollback. |
| 3. Incident bridge | User-space: a systemd *user* unit plus a Quickshell plugin. | Low; the watcher does need Docker socket access. |

Proposals 1 and 3 are user-space and backwards compatible. Proposal 2 is
neither.

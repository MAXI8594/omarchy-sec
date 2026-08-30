# 📬 Upstream PR Proposals for Omarchy & DHH

To bring these enterprise-grade security capabilities to the entire Omarchy community, we propose three concrete, targeted pull requests to the upstream Omarchy repository:

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
* When a high-severity security anomaly is detected (Level >= 10), Omarchy launches the coding agent with pre-populated incident telemetry, allowing the AI to investigate the root cause and execute containment.

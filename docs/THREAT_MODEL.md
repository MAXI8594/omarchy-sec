# Threat Model & MITRE ATT&CK Mapping for Omarchy Workstations

This is the threat model the project is built around. Read the last two columns
carefully: **what detects a thing** and **what the project does about it** are
different questions, and today the second answer is almost always "it tells you".

Two facts that constrain everything below:

- **This repository ships no custom Wazuh rules.** Detection comes entirely from
  the upstream ruleset bundled in the `wazuh/wazuh-manager:4.14.7` image, plus
  whatever the agent's own `ossec.conf` collects. Specific rule IDs therefore
  depend on the shipped Wazuh version and are not pinned here.
- **No active response is configured.** `wazuh_manager.conf` declares the
  `firewall-drop`, `host-deny`, `route-null`, `disable-account` and
  `restart-wazuh` commands, but the `<active-response>` block that would bind
  them to rules is commented out. Nothing is blocked or killed automatically.

## Threat vectors

| Threat Vector | Real-World Scenario | Detection source in this stack | What happens today |
| :--- | :--- | :--- | :--- |
| **Malicious Package Post-Install** | Compromised `npm`/`pip`/`gem` dependency spawning a reverse shell | Upstream Wazuh rules over agent log/command collection (T1059.004 — Unix Shell) | Alert. At level ≥ 10 the AI agent opens with the alert, `ss -tuln` and `ps aux` preloaded; it proposes containment, the user runs it. |
| **Dotfile Tampering** | Malware modifying `~/.config/hypr/hyprland.conf` or `~/.bashrc` for persistence | FIM (T1546.004 — Shell Init Scripts) — **but only for paths the agent monitors.** The manager config here covers `/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`; `$HOME` is **not** monitored out of the box and must be added to the agent's `syscheck` stanza. | Alert on checksum change, once the path is monitored. No rollback is wired — Btrfs/Snapper recovery is a manual step, not something the project performs. |
| **Privilege Escalation** | Unauthorized setuid binary, or sudoers abuse | Upstream sudo/PAM rules (T1548.001 — Setuid/Setgid) | Alert only. |
| **SSH Brute-Force** | Scanning against port 22 on LAN or a public IP | Upstream `sshd` decoder and rules (T1110.001 — Password Guessing) | Alert only. `pam_faillock` lockout and UFW/nftables blocking are **not** configured by this project; both are host configuration the user still has to do. |
| **Ransomware / Mass Encryption** | Script iterating and encrypting user directories | FIM frequency anomalies (T1486 — Data Encrypted for Impact), subject to the same "only monitored paths" caveat | Alert, and at level ≥ 10 an AI agent session. Endpoint network isolation is not automated. |

## Gap list

Stated so a reviewer does not have to find it:

1. `$HOME` is outside FIM by default, which blunts the dotfile and ransomware
   rows above — the two most Omarchy-specific vectors in the table.
2. No active response means detection-to-containment is entirely human-paced.
3. `<use_password>no</use_password>` in the manager's `auth` stanza: agent
   enrollment on `:1515` is unauthenticated. Acceptable only because the port is
   bound to `127.0.0.1`; it stops being acceptable the moment anyone rebinds it
   to a LAN interface to enroll a second host.

# Threat Model & MITRE ATT&CK Mapping for Omarchy Workstations

## Threat Actors & Attack Vectors

| Threat Vector | Real-World Scenario | Wazuh Detection Rule / Technique | Automated Response |
| :--- | :--- | :--- | :--- |
| **Malicious Package Post-Install** | Compromised `npm`/`pip`/`gem` dependency spawning reverse shell | Rule ID `100201` (T1059.004 - Unix Shell) | AI Agent identifies PID and parent process, kills PID, blocks remote IP. |
| **Dotfile Tampering** | Malware modifying `~/.config/hypr/hyprland.conf` or `~/.bashrc` for persistence | FIM Syscheck (T1546.004 - Shell Init Scripts) | FIM alerts on SHA256 mismatch; agent offers rollback via Btrfs/Snapper snapshot. |
| **Privilege Escalation** | Unauthorized binary execution with setuid or abusing sudoers | Rule ID `5402` (T1548.001 - Setuid/Setgid) | Logs PAM authentication; alerts on sudo violation. |
| **SSH Brute-Force** | Scanning attacks against port 22 on LAN or public IP | Rule ID `5710` (T1110.001 - Password Guessing) | `pam_faillock` triggers at 10 attempts; IP blocked via UFW/nftables. |
| **Ransomware / Mass Encryption** | Malicious script iterating and encrypting user directories | FIM Frequency Anomaly (T1486 - Data Encrypted for Impact) | Alert Level 12 triggers; AI agent isolates endpoint from network. |

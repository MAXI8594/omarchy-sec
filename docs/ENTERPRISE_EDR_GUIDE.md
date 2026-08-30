# 🏢 Enterprise EDR, XDR & MDR Deployment Guide for Omarchy Linux

## Executive Overview

Modern enterprise environments require central SOC teams to maintain real-time visibility, continuous compliance, and autonomous incident containment across all corporate endpoints.

While developer workstations running **Omarchy Linux (Arch Linux + Hyprland)** offer unmatched productivity, commercial EDR vendors rarely provide native `.pkg.tar.zst` packages. This guide provides the complete, battle-tested engineering blueprint for deploying and managing enterprise security sensors (**CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex XDR, and Wazuh**) on Omarchy workstations, ensuring full fleet management from corporate cloud consoles.

---

## 🏗️ Enterprise Architecture & Fleet Visibility

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CORPORATE SOC CLOUD CONSOLES                         │
│  (Falcon Cloud • Defender Security Portal • SentinelOne Console • SOC) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Egress TLS/443 Telemetry Stream)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   OMARCHY ENTERPRISE WORKSTATIONS                      │
│                                                                        │
│  ┌───────────────────────┐              ┌───────────────────────────┐  │
│  │   CORPORATE SENSOR    │              │   OMARCHY SEC SENTINEL    │  │
│  │  (Falcon / MDE / S1)  │ <----------> │    (Bar Widget & Panel)   │  │
│  │ eBPF Kernel Telemetry │              │  Real-Time Health Status  │  │
│  └───────────┬───────────┘              └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │              AUTONOMOUS LOCAL AI INCIDENT RESPONDER              │  │
│  │                  (`omarchy-sec agent` Bridge)                    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Package Conversion Strategies on Arch Linux

Corporate IT departments usually distribute EDR installers as `.deb` (Debian/Ubuntu) or `.rpm` (RHEL/CentOS/SLES) binaries. Use these standard conversion workflows:

### Method 1: `debtap` (Debian/Ubuntu `.deb` packages)
Converts `.deb` into a native Arch package (`.pkg.tar.zst`), creating pacman-tracked files and systemd service links.

```bash
paru -S --needed debtap
sudo debtap -u
debtap <installer-package>.deb
sudo pacman -U <installer-package>-1-x86_64.pkg.tar.zst
```

### Method 2: `rpmextract` / `bsdtar` (Red Hat / SLES `.rpm` packages)
Extracts directory hierarchies (`/opt`, `/etc/systemd/system`) directly into the root filesystem.

```bash
paru -S --needed rpmextract
cd /
sudo rpmextract.sh /path/to/<installer-package>.rpm
sudo systemctl daemon-reload
```

---

## 🛠️ Step-by-Step Vendor Installation Playbooks

### 1. 🦅 CrowdStrike Falcon Sensor (`falcon-sensor`)
CrowdStrike provides kernel-level endpoint detection and threat graph correlation.

* **Dependencies:** `linux-headers`, `libnl`, `openssl`.
* **Installation:**
  ```bash
  cd /
  sudo rpmextract.sh falcon-sensor-<version>.amzn2.x86_64.rpm
  sudo systemctl daemon-reload
  ```
* **Cloud Onboarding:**
  ```bash
  # Register Customer ID (CID)
  sudo /opt/CrowdStrike/falconctl -s -f --cid="<CUSTOMER_ID_HEX>"
  
  # Ensure sensor operates in eBPF mode on modern kernels
  sudo /opt/CrowdStrike/falconctl -s --rfm-state=false
  
  # Enable and start daemon
  sudo systemctl enable --now falcon-sensor
  ```
* **Verification:**
  ```bash
  sudo /opt/CrowdStrike/falconctl -g --cid --rfm-state --version
  ```

---

### 2. 🛡️ Microsoft Defender for Endpoint (`mdatp`)
Enterprise endpoint protection integrated into Microsoft 365 Defender Portal.

* **Dependencies:** `audit`, `mde-netfilter` (or eBPF).
* **Installation via `debtap`:**
  ```bash
  debtap -u
  debtap mdatp_*.deb
  sudo pacman -U mdatp-*.pkg.tar.zst
  ```
* **Cloud Onboarding:**
  Execute your organization's Python onboarding package (`MicrosoftDefenderATPOnboardingLinuxClient.py`):
  ```bash
  sudo python3 MicrosoftDefenderATPOnboardingLinuxClient.py
  ```
* **Verification:**
  ```bash
  mdatp health --field org_id
  mdatp health --field healthy
  mdatp connectivity test
  ```

---

### 3. 🟣 SentinelOne Singularity Linux Agent (`sentinelone`)
Autonomous AI-driven behavioral EDR.

* **Installation:**
  ```bash
  cd /
  sudo rpmextract.sh SentinelAgent-<version>.rpm
  sudo systemctl daemon-reload
  ```
* **Cloud Onboarding:**
  ```bash
  # Set Corporate Site Token
  sudo /opt/sentinelone/bin/sentinelctl control site-token set "<SITE_TOKEN>"
  
  # Enable and start service
  sudo systemctl enable --now sentinelone
  ```
* **Verification:**
  ```bash
  sudo /opt/sentinelone/bin/sentinelctl status
  ```

---

### 4. 🔷 Palo Alto Networks Cortex XDR (`cortex-agent` / `traps`)
Behavioral threat protection and network analytics.

* **Installation:**
  Run the corporate self-extracting `.sh` installer:
  ```bash
  sudo chmod +x cortex-installer.sh
  sudo ./cortex-installer.sh --distribution-token="<DISTRIBUTION_TOKEN>"
  ```
* **Verification:**
  ```bash
  sudo /opt/traps/bin/cytool check
  sudo /opt/traps/bin/cytool enum
  ```

---

### 5. 🐺 Wazuh Agent (Open Source & Managed SOC)
Host-based SIEM, FIM, and SCA compliance.

* **Installation:**
  ```bash
  paru -S --needed wazuh-agent
  ```
* **Registration & Cloud Connection:**
  ```bash
  sudo /var/ossec/bin/agent-auth -m <MANAGER_IP_OR_FQDN> -P "<REGISTRATION_PASSWORD>" -A "$(hostname)"
  sudo sed -i 's/<address>.*<\/address>/<address><MANAGER_IP_OR_FQDN><\/address>/' /var/ossec/etc/ossec.conf
  sudo systemctl enable --now wazuh-agent
  ```

---

## 🔒 Zero Trust Network Microsegmentation

To ensure full corporate compliance without compromising Omarchy security:

1. **Egress-Only TLS / Port 443:** All modern EDR agents maintain persistent, outbound-only connections (HTTPS/gRPC/WebSockets) to cloud telemetry backends.
2. **Inbound Deny:** No local listening ports are required on Omarchy workstations. Default UFW policy (`ufw default deny incoming`) remains fully intact.
3. **Auditd Conflict Prevention:** Modern Linux kernels support eBPF probes. If an EDR requires the audit subsystem, configure `auditd` with `backlog_wait_time` to prevent kernel throttling.

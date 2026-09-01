# 🏢 Enterprise EDR, XDR & MDR Deployment Guide for Omarchy Linux

## Executive Overview

Central SOC teams need continuous visibility and compliance evidence across every corporate endpoint, including the Linux workstations their developers insist on.

Commercial EDR vendors rarely ship native `.pkg.tar.zst` packages, so getting a
corporate sensor (**CrowdStrike Falcon, Microsoft Defender, SentinelOne, Cortex
XDR, Wazuh**) onto an Arch-based workstation means converting or extracting
someone else's package format.

> **What this guide is, and is not.** It collects the vendor-documented
> installation and enrollment steps, arranged for Arch Linux. The commands mirror
> what `bin/omarchy-sec-onboard` runs or prints for each vendor, so the CLI
> wizard and this page stay in step. They are **not** verified by this
> repository's CI — no vendor sensor is installed in the pipeline, and vendors
> change their installers and flags between versions. Treat this as a starting
> point to check against your vendor's current documentation and your own
> licensing terms, not as a validated blueprint.

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
│  │            LOCAL AI-ASSISTED INCIDENT RESPONDER                  │  │
│  │       (`omarchy-sec agent` — auto-triggered, human-driven)        │  │
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
Host-based SIEM, FIM, and SCA.

* **Installation:**
  ```bash
  paru -S --needed wazuh-agent
  ```
* **Registration & Manager Connection:**
  ```bash
  sudo /var/ossec/bin/agent-auth -m <MANAGER_IP_OR_FQDN> -P "<REGISTRATION_PASSWORD>" -A "$(hostname)"
  sudo sed -i 's/<address>.*<\/address>/<address><MANAGER_IP_OR_FQDN><\/address>/' /var/ossec/etc/ossec.conf
  sudo systemctl enable --now wazuh-agent
  ```
  Drop `-P` when the manager does not require an enrollment password. The
  single-node stack in this repository is one such case: its `auth` stanza sets
  `<use_password>no</use_password>`, and enrollment is contained by the fact
  that `:1515` is bound to `127.0.0.1`. `setup.sh` enrolls the local host with
  `agent-auth -m 127.0.0.1` accordingly. If you rebind that port to reach other
  hosts, turn the enrollment password back on.
* **File integrity scope:** the manager config in this repository watches
  `/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin` and `/boot`. `$HOME` is not
  monitored by default — add it to the agent's `syscheck` stanza if you need
  dotfile tampering coverage.

---

## 🔒 Zero Trust Network Microsegmentation

To keep corporate telemetry flowing without widening the workstation's attack
surface:

1. **Egress-Only TLS (cloud sensors):** A cloud-managed sensor keeps a
   persistent outbound connection to its vendor backend and needs no inbound
   port. Omarchy's default `ufw default deny incoming` stays intact.
2. **Loopback-only listeners (local Wazuh stack):** If you deploy the
   `docker/single-node/` stack instead of, or alongside, a cloud sensor, it
   **does** listen — six published ports (`1514`, `1515`, `514/udp`, `55000`,
   `9200`, `9001`), every one bound to `127.0.0.1`. Nothing is reachable from
   the network, but they are listening, and any local user can reach them. See
   [`ZERO_TRUST_MICROSEGMENTATION.md`](ZERO_TRUST_MICROSEGMENTATION.md) for the
   full table and the consequences.
3. **Auditd Conflict Prevention:** Modern Linux kernels support eBPF probes. If
   an EDR requires the audit subsystem instead, configure `auditd` with
   `backlog_wait_time` to prevent kernel throttling.

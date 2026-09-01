# 🏢 Enterprise EDR & MDR Deployment Playbooks

Step-by-step installation and cloud onboarding playbooks for corporate EDR
sensors on Arch Linux / Omarchy.

> **Scope.** These are the vendor-documented steps, arranged for Arch, and they
> mirror what `bin/omarchy-sec-onboard` runs or prints. They are **not** verified
> by this project's CI — no vendor sensor is installed in the pipeline, and
> vendors change installers and flags between versions. Check them against your
> vendor's current documentation.

---

## 1. 🦅 CrowdStrike Falcon Sensor

* **Package:** `falcon-sensor-<version>.amzn2.x86_64.rpm`
* **Deployment:**
  ```bash
  cd /
  sudo rpmextract.sh /path/to/falcon-sensor-*.rpm
  sudo systemctl daemon-reload
  ```
* **Cloud Onboarding:**
  ```bash
  sudo /opt/CrowdStrike/falconctl -s -f --cid="<CUSTOMER_ID>"
  sudo /opt/CrowdStrike/falconctl -s --rfm-state=false
  sudo systemctl enable --now falcon-sensor
  ```
* **CLI Wizard:** `omarchy-sec onboard falcon`

---

## 2. 🛡️ Microsoft Defender for Endpoint (MDE)

* **Package:** `mdatp_*.deb`
* **Deployment via `debtap`:**
  ```bash
  debtap -u
  debtap mdatp_*.deb
  sudo pacman -U mdatp-*.pkg.tar.zst
  ```
* **Cloud Onboarding:**
  ```bash
  sudo python3 MicrosoftDefenderATPOnboardingLinuxClient.py
  mdatp connectivity test
  ```
* **CLI Wizard:** `omarchy-sec onboard defender`

---

## 3. 🟣 SentinelOne Singularity

* **Package:** `SentinelAgent-*.rpm`
* **Deployment:**
  ```bash
  cd /
  sudo rpmextract.sh SentinelAgent-*.rpm
  sudo /opt/sentinelone/bin/sentinelctl control site-token set "<SITE_TOKEN>"
  sudo systemctl enable --now sentinelone
  ```
* **CLI Wizard:** `omarchy-sec onboard sentinelone`

---

## 4. 🔷 Palo Alto Networks Cortex XDR

* **Package:** `cortex-installer.sh`
* **Deployment:**
  ```bash
  sudo ./cortex-installer.sh --distribution-token="<TOKEN>"
  sudo /opt/traps/bin/cytool check
  ```
* **CLI Wizard:** `omarchy-sec onboard cortex`

---

## 5. 🐺 Wazuh Agent (Open Source MDR)

* **Package:** AUR `aur/wazuh-agent`
* **Deployment:**
  ```bash
  paru -S --needed wazuh-agent
  sudo /var/ossec/bin/agent-auth -m <MANAGER_IP> -A "$(hostname)"
  sudo systemctl enable --now wazuh-agent
  ```
  Add `-P "<password>"` when the manager requires an enrollment password. The
  single-node stack shipped with this project does not: its `auth` stanza sets
  `<use_password>no</use_password>`, and enrollment is contained only by
  `:1515` being bound to `127.0.0.1`.
* **File integrity scope:** the shipped manager config watches `/etc`,
  `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin` and `/boot`. `$HOME` is not monitored
  by default — add it to the agent's `syscheck` stanza for dotfile coverage.
* **CLI Wizard:** `omarchy-sec onboard wazuh`

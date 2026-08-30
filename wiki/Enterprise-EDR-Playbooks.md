# 🏢 Enterprise EDR & MDR Deployment Playbooks

Step-by-step installation and cloud onboarding playbooks for corporate EDR sensors on Arch Linux / Omarchy:

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
* **CLI Wizard:** `omarchy-sec onboard wazuh`

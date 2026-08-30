#!/bin/bash

# ==============================================================================
# Omarchy Sec - Open Email Composer Pre-Filled for Omarchy Security Team & DHH
# ==============================================================================

set -euo pipefail

TO="security@omarchy.org"
CC="david@omarchy.org"
SUBJECT="[Security Improvement & PR Proposal] Workstation Hardening & EDR Telemetry for Omarchy (omarchy-sec)"

BODY=$(cat << 'BODY_EOF'
Hi Omarchy Security Team & DHH,

I'm an active user and developer building on Omarchy Linux. First of all, thank you for crafting such a cohesive, opinionated, and delightful developer workstation environment.

As more developers begin adopting Omarchy in corporate and high-compliance enterprise settings, developer workstations are increasingly scrutinized as high-value targets (npm/pip dependency confusion, dotfile tampering, and unauthorized reverse shells). 

I have conducted a security audit and built a modular suite called Omarchy Sec (https://github.com/MAXI8594/omarchy-sec). Based on this work, I would like to propose three targeted, zero-bloat upstream security improvements for core Omarchy, as well as share our agnostic EDR integration.

Per your security policy, these are designed as proactive security hardening improvements that respect Omarchy's user-space philosophy without introducing breaking changes or runtime overhead.

======================================================================
1. THREE CONCRETE UPSTREAM PR PROPOSALS
======================================================================

1. Proposal 1: omarchy firewall CLI Command Group
   • Problem: While Omarchy enables UFW with an inbound deny policy by default, developers frequently struggle with raw iptables/ufw syntax when opening local test ports (Rails, Next.js, Postgres).
   • Proposed Solution: Add a native, declarative CLI helper:
       omarchy firewall status                     # Clean, visual port & rule inspector
       omarchy firewall allow <port> [--proto=tcp] # Allow port with automated comment
       omarchy firewall deny <port>                # Revoke port access
       omarchy firewall reset                      # Restore default Omarchy deny policy

2. Proposal 2: Default SSHD Hardening (omarchy setup security sshd)
   • Problem: When fetching public keys from GitHub via omarchy setup security sshd, the underlying OpenSSH daemon configuration may still permit password authentication on LAN or Tailscale interfaces.
   • Proposed Solution: Drop in /etc/ssh/sshd_config.d/99-omarchy-hardened.conf enforcing:
       PasswordAuthentication no
       KbdInteractiveAuthentication no
       PubkeyAuthentication yes
       MaxAuthTries 3

3. Proposal 3: Security Incident Diagnostics for omarchy-agent
   • Problem: Omarchy provides excellent post-mortem diagnostics (omarchy agent crash <pid>), but lacks runtime security incident triage.
   • Proposed Solution: Add a security incident hook that allows omarchy-agent to receive high-severity telemetry (abnormal sockets, unexpected /tmp execution) and assist the developer with instant triage and containment.

Full PR specification: 
👉 https://github.com/MAXI8594/omarchy-sec/blob/main/docs/OMARCHY_UPSTREAM_PR.md

======================================================================
2. THE OPEN-SOURCE COMPANION SUITE: OMARCHY SEC
======================================================================

To demonstrate these concepts in production, we built and released Omarchy Sec:
• GitHub: https://github.com/MAXI8594/omarchy-sec
• Agnostic Sensor Detection: Auto-detects and aggregates telemetry from CrowdStrike Falcon, Microsoft Defender (MDE), SentinelOne, Cortex XDR, and Wazuh.
• Zero Trust Microsegmentation: 100% outbound-only TLS/443 telemetry streaming (zero inbound listening ports required on workstations).
• Quickshell Top Bar Widget: Native io.github.maxi8594.omarchy-sec widget with live status and interactive "Call Agent" SOC AI bridge.
• DevSecOps Verified: 100% passed in SAST (ShellCheck), IaC (Trivy), Secrets Scanning (Gitleaks/TruffleHog), and DAST.

======================================================================
3. NEXT STEPS & COLLABORATION
======================================================================

I have attached our technical executive report (OMARCHY_SEC_ENTERPRISE_REPORT.pdf).

I would love to open clean, separate Pull Requests for the omarchy firewall and sshd hardening improvements on the main Omarchy repository whenever you are ready to review them.

Thank you for your time and for continuing to push Linux workstation ergonomics forward.

Best regards,

Maximiliano Olivera (MAXI8594)
Security & Software Engineer
GitHub: https://github.com/MAXI8594
Project: https://github.com/MAXI8594/omarchy-sec
BODY_EOF
)

# URL Encode function
urlencode() {
  python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))"
}

ENCODED_SUB=$(echo -n "$SUBJECT" | urlencode)
ENCODED_BODY=$(echo -n "$BODY" | urlencode)

# 1. Intentar abrir en Gmail Web composer
GMAIL_URL="https://mail.google.com/mail/?view=cm&fs=1&to=${TO}&cc=${CC}&su=${ENCODED_SUB}&body=${ENCODED_BODY}"
echo "[*] Abriendo redactor de correo en tu navegador predeterminado..."
xdg-open "$GMAIL_URL" 2>/dev/null || xdg-open "mailto:${TO}?cc=${CC}&subject=${ENCODED_SUB}&body=${ENCODED_BODY}" 2>/dev/null || true

echo ""
echo "=========================================================="
echo " ✅ Redactor de correo abierto."
echo " 📎 Recuerda adjuntar el archivo:"
echo "    /home/max/Projects/omarchy-sec/docs/OMARCHY_SEC_ENTERPRISE_REPORT.pdf"
echo "=========================================================="

# 🧪 DevSecOps Quality & Security Pipeline

Before any release or pull request, **Omarchy Sec** executes a 6-tier automated quality gate:

```text
======================================================================
 🛡️  OMARCHY SEC: PRE-PR DEVSECOPS & QUALITY PIPELINE                 
======================================================================

[1/6] SAST: Shell Script Analysis (shellcheck)...
  ✓ PASS: ShellCheck: 0 issues found across all bash scripts

[2/6] SAST: Omarchy Plugin & QML Manifest Validation...
  ✓ PASS: Omarchy Plugin Validator: 0 schema or import errors

[3/6] Secrets Scanning (Gitleaks & TruffleHog)...
  ✓ PASS: Gitleaks: No leaked secrets, credentials, or private keys

[4/6] IaC & Misconfiguration Scanning (Trivy)...
  ✓ PASS: Trivy IaC: Docker compose definitions passed security audit

[5/6] Functional: Sensor Detection Engine Verification...
  ✓ PASS: Detection Engine: Functional (Wazuh EDR, Status: protected)

[6/6] DAST: SOC Dashboard Port Connectivity (https://localhost:9001)...
  ✓ PASS: DAST Health Check: Port 9001 responsive (HTTP 302)

======================================================================
 Test Results: 6 Passed | 0 Failed
======================================================================
 ✅ All Pre-PR Security & Quality Gates PASSED.
```

## Running Locally
```bash
./tests/run_tests.sh
```

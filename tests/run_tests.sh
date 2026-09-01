#!/bin/bash

# ==============================================================================
# Omarchy Sec - Pre-PR DevSecOps & Quality Assurance Pipeline
# ==============================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0
PASSED=0

echo "======================================================================"
echo " 🛡️  OMARCHY SEC: PRE-PR DEVSECOPS & QUALITY PIPELINE                 "
echo "======================================================================"
echo ""

# 1. SAST: ShellCheck
echo "[1/6] SAST: Shell Script Analysis (shellcheck)..."
if command -v shellcheck >/dev/null 2>&1; then
  # Se listan solo los directorios que existen: scripts/ se fue con el wiki, y
  # un find contra una ruta inexistente hacia fallar el gate por el motivo
  # equivocado.
  SC_DIRS=()
  for d in bin scripts; do [ -d "$BASE_DIR/$d" ] && SC_DIRS+=("$BASE_DIR/$d"); done
  if find "${SC_DIRS[@]}" -type f -executable -exec shellcheck {} + \
     && shellcheck "$BASE_DIR"/*.sh "$BASE_DIR"/tests/*.sh; then
    echo "  ✓ PASS: ShellCheck: 0 issues found across all bash scripts"
    PASSED=$((PASSED + 1))
  else
    echo "  ✗ FAIL: ShellCheck detected issues"
    FAILED=$((FAILED + 1))
  fi
else
  echo "  ⚠ SKIP: shellcheck not installed"
fi

# 2. Omarchy Plugin Validator
echo ""
# El widget vive en su propio repo (MAXI8594/omarchy-sec-plugin). Se valida el
# checkout que este al lado o el que este instalado; si no hay ninguno, SKIP —
# este repo ya no es un plugin y validarlo contra si mismo siempre falla.
echo "[2/6] SAST: Omarchy Plugin & QML Manifest Validation..."
PLUGIN_DIR=""
for candidate in \
  "$BASE_DIR/../omarchy-sec-plugin" \
  "$HOME/.config/omarchy/plugins/io.github.maxi8594.omarchy-sec"; do
  [ -f "$candidate/manifest.json" ] && PLUGIN_DIR="$candidate" && break
done

if ! command -v omarchy >/dev/null 2>&1; then
  echo "  ⚠ SKIP: omarchy CLI not available in path"
elif [ -z "$PLUGIN_DIR" ]; then
  echo "  ⚠ SKIP: no se encontro un checkout del plugin para validar"
elif omarchy plugin validate "$PLUGIN_DIR"; then
  echo "  ✓ PASS: Omarchy Plugin Validator: 0 schema or import errors ($PLUGIN_DIR)"
  PASSED=$((PASSED + 1))
else
  echo "  ✗ FAIL: Omarchy Plugin Validator failed ($PLUGIN_DIR)"
  FAILED=$((FAILED + 1))
fi

# 3. Secrets Scanning: Gitleaks
echo ""
echo "[3/6] Secrets Scanning (Gitleaks)..."
if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks detect --source="$BASE_DIR" --no-git -v >/dev/null 2>&1; then
    echo "  ✓ PASS: Gitleaks: No leaked secrets, credentials, or private keys"
    PASSED=$((PASSED + 1))
  else
    echo "  ✗ FAIL: Potential secrets or API tokens detected"
    FAILED=$((FAILED + 1))
  fi
else
  echo "  ⚠ SKIP: gitleaks not installed"
fi

# 4. IaC Security Scan: Trivy
echo ""
echo "[4/6] IaC & Misconfiguration Scanning (Trivy)..."
if command -v trivy >/dev/null 2>&1; then
  if trivy config "$BASE_DIR/docker/single-node" --severity HIGH,CRITICAL --exit-code 1 >/dev/null 2>&1; then
    echo "  ✓ PASS: Trivy IaC: Docker compose definitions passed security audit"
    PASSED=$((PASSED + 1))
  else
    echo "  ✗ FAIL: Misconfiguration detected in Docker stack"
    FAILED=$((FAILED + 1))
  fi
else
  echo "  ⚠ SKIP: trivy not installed"
fi

# 5. Functional Detection Engine Test
echo ""
echo "[5/6] Functional: Sensor Detection Engine Verification..."
if "$BASE_DIR/bin/omarchy-sec-detect" >/dev/null 2>&1; then
  DETECT_OUTPUT="$("$BASE_DIR/bin/omarchy-sec-detect")"
  ENGINE_NAME=$(echo "$DETECT_OUTPUT" | jq -r '.primary // "unknown"')
  ENGINE_STATUS=$(echo "$DETECT_OUTPUT" | jq -r '.status // "unknown"')
  echo "  ✓ PASS: Detection Engine: Functional ($ENGINE_NAME, Status: $ENGINE_STATUS)"
  PASSED=$((PASSED + 1))
else
  echo "  ✗ FAIL: omarchy-sec-detect returned error code"
  FAILED=$((FAILED + 1))
fi

# 6. DAST Connectivity Check
echo ""
echo "[6/6] DAST: SOC Dashboard Port Connectivity (https://localhost:9001)..."
# Sonda de alcanzabilidad, no un DAST. Si el stack no esta levantado es un SKIP,
# no un PASS: antes las dos ramas sumaban PASSED, asi que este check no podia
# fallar ni cuando el dashboard estaba caido.
DASH_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 5 https://localhost:9001/ 2>/dev/null || echo "000")
if [ "$DASH_CODE" = "000" ]; then
  echo "  ⚠ SKIP: SOC dashboard no responde en :9001 (stack apagado)"
elif echo "$DASH_CODE" | grep -qE "^(200|302)$"; then
  echo "  ✓ PASS: SOC dashboard responde (HTTP $DASH_CODE)"
  PASSED=$((PASSED + 1))
else
  echo "  ✗ FAIL: SOC dashboard respondio HTTP $DASH_CODE"
  FAILED=$((FAILED + 1))
fi

echo ""
echo "======================================================================"
echo " Test Results: $PASSED Passed | $FAILED Failed"
echo "======================================================================"

if [ "$FAILED" -eq 0 ]; then
  echo " ✅ All Pre-PR Security & Quality Gates PASSED."
  exit 0
else
  echo " ❌ Pipeline failed. Please resolve above issues before submitting PR."
  exit 1
fi

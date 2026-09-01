# 🧪 DevSecOps Quality & Security Pipeline

Two things run, and they are not the same set of checks: `tests/run_tests.sh`
locally, on demand, and `.github/workflows/security-ci.yml` on every push and
pull request to `main`.

## Local pipeline — `tests/run_tests.sh`

| # | Check | Tool | Fails the run? |
| :--- | :--- | :--- | :--- |
| 1 | Shell static analysis | `shellcheck` over `bin/` and `scripts/` | Yes — skipped if `shellcheck` is absent |
| 2 | Plugin & QML manifest validation | `omarchy plugin validate` | Yes — skipped if the `omarchy` CLI or a plugin checkout is absent |
| 3 | Secrets scanning | `gitleaks detect --no-git` | Yes — skipped if `gitleaks` is absent |
| 4 | IaC misconfiguration | `trivy config docker/single-node --severity HIGH,CRITICAL --exit-code 1` | Yes — skipped if `trivy` is absent |
| 5 | Detection engine smoke test | runs `bin/omarchy-sec-detect` | Yes |
| 6 | SOC dashboard reachability | `curl` against `https://localhost:9001` | Yes on an unexpected HTTP status; **skipped** when the stack is down |

```bash
./tests/run_tests.sh
```

## CI pipeline — `.github/workflows/security-ci.yml`

Four steps on `ubuntu-latest`:

1. **ShellCheck** (`ludeeus/action-shellcheck`, `scandir: ./bin`)
2. **Gitleaks** (`gitleaks/gitleaks-action@v2`)
3. **Semgrep** (`p/security-audit`, `p/secrets`, `p/bash`)
4. **Trivy** in `config` mode against `docker/single-node`

## What this pipeline does *not* do

Stated plainly, because the labels above are easy to over-read:

- **There is no SCA.** Nothing scans dependencies or container images, in either
  pipeline, despite the CI workflow's name mentioning it. (Separately, the
  running Wazuh stack does have `<vulnerability-detection>` enabled against the
  package inventory it collects — that is a runtime feature of the deployed
  stack, not a gate on this repository's code.)
- **TruffleHog is not used.** Only Gitleaks runs. Earlier versions of this page
  listed both; that was wrong.
- **Check 6 is a reachability probe, not DAST.** It asks whether
  `https://localhost:9001` answers. It does not fuzz, crawl, or test the
  application. The script's own output still labels it `DAST:` — read it as
  "the dashboard is up".
- **Checks 1–4 skip silently when the tool is not installed.** A skip is neither
  a pass nor a failure and the run still exits 0, so on a bare machine four of
  the six checks evaporate and the pipeline reports success. This is the biggest
  remaining gap.
- **Check 5 verifies that the script runs, not that the machine is protected.**
  `omarchy-sec-detect` exits 0 whether or not any sensor is active.
- **Semgrep runs only in CI**, never locally; **`omarchy plugin validate` runs
  only locally**, never in CI (the Omarchy CLI is not available on a GitHub
  runner); and **CI scans only `bin/`**, while the local run also covers
  `scripts/`.

The genuinely enforcing gates today are ShellCheck, Gitleaks, Semgrep, and —
when the tools are installed — Trivy and the two functional checks.

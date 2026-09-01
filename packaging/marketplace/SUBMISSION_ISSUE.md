# Omarchy Plugin Marketplace — submission issue (ready to paste)

> Do **not** open the issue from this file automatically. A human opens it.
> Source of truth for this format: `SUBMISSION.md` in `omacom/omarchy-plugin-marketplace`
> (fetched 2026-09-01) and `.github/ISSUE_TEMPLATE/submit-plugin.yml`.

## Where to open it

Blank issue (paste the body below verbatim — blank issues are enabled):

    https://github.com/omacom/omarchy-plugin-marketplace/issues/new

Or the web form (dropdowns must be picked by hand, the body below is then only a crib):

    https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml

## Exact title

    [Plugin]: Omarchy Sec

(`title:` in the template is `"[Plugin]: "`, so the prefix plus the human-readable
name from `manifest.json` → `name: "Omarchy Sec"`.)

## Pre-flight checklist (verify by hand before sending)

- [ ] `gh api user --jq .login` returns `MAXI8594` — the plugin repo is personal, not an Andreani org.
- [ ] Repo HEAD is still `ecbbf3fa5b510653bb7baa81c42c7f49603270d2`. Validation binds to the exact
      commit that is HEAD when the issue opens; pushing after opening invalidates the scan.
- [ ] https://omarchyplugins.com/ has no listing using `io.github.maxi8594.omarchy-sec`
      (registry.json checked 2026-09-01: not present, not in `retiredPluginIds`).
- [ ] All five checklist boxes below are true for you, and stay `[x]`.
- [ ] The six `###` headings are present, in this order, unrenamed.
- [ ] Category string is `System` — case-sensitive, no backticks.
- [ ] Tags are at most three. Four or more = automatic rejection.
- [ ] After opening: expect the validation bot **and** the Automated Security Baseline to comment.
      Do not open a second issue on failure — edit this one, which re-runs detection.

## Category choice

Chosen: **System**. The two closest listed analogs are `devinblack001.wazuh-view`
(System, `security bar quickshell`) and `io.github.omarkamal.security-posture`
(System, `security system quickshell`) — both are endpoint-security status readouts,
same shape as this plugin.

Alternative, defensible if a reviewer reclassifies: **Widgets** — the largest bucket
(645 listings) and where most generic bar widgets land, e.g. `io.github.elynch303.security-scan`
(Widgets, `security bar system`). Either is accepted in practice; do not re-open to change it.

Tags `security, bar, quickshell` match `wazuh-view` exactly. `system` is the obvious
swap-in if `quickshell` feels redundant.

---

# COPY EVERYTHING BELOW THIS LINE INTO THE ISSUE BODY

```
### Repository URL

https://github.com/MAXI8594/omarchy-sec-plugin

### Category

System

### Tags

security, bar, quickshell

### Suggest a missing tag

_No response_

### Maintainer notes

Omarchy Sec is a Quickshell bar widget that reports whether an endpoint security
sensor is actually running on the machine. It probes Wazuh, CrowdStrike Falcon,
Cortex XDR, SentinelOne, Microsoft Defender (mdatp), Falco/Tetragon and auditd,
and colours a shield in the bar with three states: accent when at least one sensor
is active, urgent when none is (the endpoint is unprotected), and muted when the
detector is not installed and therefore nothing was measured. The muted state is
deliberate — a security indicator that claims "unprotected" when it simply could
not look is a false alarm. Clicking opens a panel with one row per sensor;
middle-click opens the configured SOC dashboard.

Plugin ID: io.github.maxi8594.omarchy-sec
Kind: bar-widget (single entry point, BarWidget.qml)
License: MIT, root LICENSE file.

External dependencies, all optional at install time and documented in the README:

- The `omarchy-sec` CLI (`omarchy-sec-detect`, `omarchy-sec agent`), packaged
  separately at https://github.com/MAXI8594/omarchy-sec. Without it the widget
  stays in its muted "unknown" state rather than reporting a wrong result.
- `xdg-open` from `xdg-utils`, used to open vendor consoles and the dashboard.

The widget itself runs no privileged code: no sudo, no pkexec, no installer, no
sudoers policy, no bundled binary, no downloads. It launches exactly three
commands, all as the user: `omarchy-sec-detect`, `omarchy-sec agent`, and
`xdg-open`. Any service or container state the widget displays is read by that
separately packaged CLI, not by anything in this repository.

Nothing is written outside `~/.config/omarchy/plugins/`. Removal is
`omarchy plugin disable` then `omarchy plugin remove`, both documented in the README.
No user configuration is overwritten.

`omarchy plugin validate` passes on a clean clone of the submitted commit.

### Submission checklist

- [x] The repository is public and contains installation and removal instructions.
- [x] I have documented the plugin license and any external dependencies.
- [x] I confirm that I own or have permission to submit this plugin and its preview assets.
- [x] The plugin does not overwrite user configuration without explicit consent.
- [x] I understand that approval is for listing and is not a security review.
```

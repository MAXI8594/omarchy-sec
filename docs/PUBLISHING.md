# 🚀 Publishing to the Omarchy Plugin Marketplace

This guide covers **one** of the project's three deliverables: the **Quickshell bar
widget**, which is submitted to the [Omarchy Plugin Marketplace](https://plugins.omarchy.org/).

| Deliverable | Channel | Covered here |
| :--- | :--- | :--- |
| Bar widget — [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | Marketplace submission issue | ✅ this document |
| `omarchy-sec` CLI + watcher service — this repository | AUR package ([Creating packages](https://wiki.archlinux.org/title/Creating_packages)) | ❌ see `packaging/aur/` |
| System config proposals — [`OMARCHY_UPSTREAM_PR.md`](OMARCHY_UPSTREAM_PR.md) | RFC / design doc in the Omarchy Discord, `#omarchy-security` | ❌ no marketplace step |

> **Why the widget is a separate repository.** The marketplace requires one public
> repository per plugin, and its automated scanner flags `installer`,
> `service-management` and `package-manager` capabilities for manual review. An
> installer script and a systemd unit sitting next to the QML would trigger those on
> every release, so the widget repo carries QML, a manifest, a README and a license —
> nothing else.

---

## 1. Repository Requirements

Everything below is checked against the **exact commit** you submit.

| Requirement | Detail | Status |
| :--- | :--- | :--- |
| **Public GitHub repository** | One repository per plugin. Submit the **root URL** — no trailing slash, no `/tree/main` suffix. | ✅ `https://github.com/MAXI8594/omarchy-sec-plugin` |
| **`manifest.json` at the repo root** | Not in a subdirectory. | ✅ |
| **`README` at the repo root** | Must document both **installation and removal**. | ✅ |
| **License file at the repo root** | Must also document the plugin's **external dependencies**. | ✅ `LICENSE` |
| **Globally unique plugin ID** | Must not sit inside the reserved `omarchy.*` namespace. | ✅ `io.github.maxi8594.omarchy-sec` |
| **Preview image** *(optional)* | `preview.png`, `.jpg`, `.jpeg`, `.webp` or `.avif` at the repo root. Max **50 MB** and **40 megapixels**. | ✅ `preview.png` — 482×504, 0.24 MP, 183 KB |

---

## 2. Validate Locally Before Submitting

The Omarchy CLI validates a plugin folder against the manifest schema and exits `0`
when it passes:

```bash
git clone https://github.com/MAXI8594/omarchy-sec-plugin.git
omarchy plugin validate ./omarchy-sec-plugin
echo $?     # 0 = valid
```

**A pass is silent** — the validator prints nothing and exits `0`. Check the exit code, not the output.

Then verify the documented install and removal paths actually work on a clean machine:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
omarchy plugin disable io.github.maxi8594.omarchy-sec
omarchy plugin remove  io.github.maxi8594.omarchy-sec
```

> ⚠️ **The shell caches compiled QML.** It hot-reloads on file changes in `~/.config/omarchy/plugins/`, but a QML edit will not actually take effect until you run:
> ```bash
> omarchy restart shell
> ```
> Test against a restarted shell before submitting, or you will be validating a stale build of your own widget.

---

## 3. Automated Security Scan

The submitted commit is scanned automatically. Findings fall into two classes.

### 🚫 Blocking findings

A submission carrying any of these does not proceed:

| Finding | What triggers it |
| :--- | :--- |
| `curl-pipe-shell` | Piping a downloaded script straight into a shell |
| `cargo-git-unpinned` | A `cargo` git dependency without a pinned revision |
| `remote-git-execution-unpinned` | Executing code from a git remote without pinning it |
| `sudoers-dangerous-passwordless-command` | A passwordless `sudoers` entry for a dangerous command |
| `privileged-process-control-from-shared-temp` | Privileged process control driven from a shared temp directory |

### ⚠️ Capabilities that force manual review

These do **not** block the submission, but they take it out of the automatic path and
into a human review queue:

`installer` · `package-manager` · `privilege` · `remote-build` ·
`bundled-executable-binary` · `service-management` · `sudoers-modification`

The widget repository declares none of them — that is the entire reason the CLI, the
installer and the systemd unit stayed in [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec)
and ship through the AUR instead.

---

## 4. Open the Submission Issue

👉 [**Submit Plugin to the Omarchy Marketplace**](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

The issue is parsed, not just read. Four rules matter:

1. The issue **title must start with `[Plugin]:`**.
2. The template's **headings may not be reordered or omitted** — leave them exactly as generated.
3. The **category is case-sensitive** — use the value exactly as the template's dropdown spells it.
4. **Every checkbox must be ticked.**

### Values for this submission

| Field | Value |
| :--- | :--- |
| **Plugin ID** | `io.github.maxi8594.omarchy-sec` |
| **Plugin Name** | `Omarchy Sec` |
| **Repository URL** | `https://github.com/MAXI8594/omarchy-sec-plugin` |
| **Kind** | `bar-widget` |
| **Description** | Endpoint security status in the bar: detects Wazuh, CrowdStrike Falcon, Cortex XDR, SentinelOne, Microsoft Defender, Falco/Tetragon and auditd, and dispatches incidents to the Omarchy AI agent. |
| **Category** | Take the exact spelling from the template's dropdown |

---

## 5. Review Outcome

A new listing is not published automatically. It requires an **explicit maintainer
approval** — the `approved-and-verified` decision — before it appears in the
marketplace. Until that decision lands, the plugin is installable only from its git
URL:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
```

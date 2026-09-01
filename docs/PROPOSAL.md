# RFC: Optional security hardening and EDR telemetry hooks for Omarchy

| | |
| :--- | :--- |
| **Status** | Draft — open for discussion |
| **Author** | Maximiliano Olivera ([@MAXI8594](https://github.com/MAXI8594)) |
| **Discussion** | Omarchy Discord, `#omarchy-security` |
| **Target** | Omarchy 4.x |
| **Reference implementation** | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) (out-of-tree, MIT) |

This document exists because a design doc can be diffed, quoted by line, and argued with. An earlier version of this material was circulated as a PDF; the PDF is kept in `docs/` for reference but this file is the version to review. Where the two disagree, this file wins.

**Read this first if you only read one section:** the three proposals in [§3](#3-proposals) are independent. They are not a package. Rejecting one does not affect the others, and I would rather land one than argue about three.

---

## Contents

- [1. Summary](#1-summary)
  - [1.1 What this proposes](#11-what-this-proposes)
  - [1.2 What this does not propose](#12-what-this-does-not-propose)
- [2. Problem statement](#2-problem-statement)
- [3. Proposals](#3-proposals)
  - [Proposal A — `omarchy firewall` CLI group](#proposal-a--omarchy-firewall-cli-group)
  - [Proposal B — SSH daemon hardening drop-in](#proposal-b--ssh-daemon-hardening-drop-in)
  - [Proposal C — Optional EDR telemetry hook and incident bridge](#proposal-c--optional-edr-telemetry-hook-and-incident-bridge)
- [4. What already exists out-of-tree](#4-what-already-exists-out-of-tree)
- [5. The DevSecOps pipeline behind this repo](#5-the-devsecops-pipeline-behind-this-repo)
- [6. Open questions](#6-open-questions)

---

## 1. Summary

### 1.1 What this proposes

Three additions to Omarchy, in descending order of how confident I am that they belong upstream:

1. **[`omarchy firewall`](#proposal-a--omarchy-firewall-cli-group)** — a small CLI group wrapping the UFW commands developers actually run, so opening a dev port does not mean dropping to raw `ufw`/`iptables` syntax.
2. **[SSH daemon hardening](#proposal-b--ssh-daemon-hardening-drop-in)** — an sshd drop-in that disables password authentication, applied as part of the existing SSH setup path that already installs public keys.
3. **[EDR telemetry hook](#proposal-c--optional-edr-telemetry-hook-and-incident-bridge)** — an opt-in recipe and status widget for users whose employer requires an endpoint agent, plus a documented hook so a high-severity alert can hand its context to the local coding agent.

Proposal A is a convenience wrapper over an existing default. Proposal B changes a security default. Proposal C is opt-in and adds no code paths for users who never enable it. They should be discussed and accepted or rejected separately.

### 1.2 What this does not propose

Stating the negative scope explicitly, because most of the objections I expect are to things I am not asking for:

- **No EDR agent bundled with Omarchy.** Nothing is installed by default, nothing phones home, no vendor is endorsed. Proposal C is a hook plus documentation; the sensor is whatever the user's employer already mandates, installed by the user.
- **No daemon running by default.** The watcher described in Proposal C is a user systemd unit that must be explicitly enabled. A default Omarchy install after this RFC has the same running process list as before it.
- **No telemetry to me, to this repo, or to any third party.** There is no analytics, no crash reporting, no phone-home in any of the three proposals.
- **No changes to Omarchy's aesthetic or workflow defaults.** No new bar widget appears unless the user adds one.
- **No kernel modules, no eBPF programs shipped by Omarchy.** Vendor sensors bring their own; Omarchy would not.
- **No mandatory hardening.** Proposal B is the only one that changes a default, and [its revert path](#b-cost-and-risk) is a single file deletion.
- **No claim that this makes a workstation "secure."** It reduces two specific classes of exposure (unauthenticated inbound SSH; blind spots on a machine that runs untrusted code) and does nothing about the rest.

---

## 2. Problem statement

Omarchy targets developers, and a developer workstation has an unusual threat profile compared with a general-purpose desktop:

**It executes untrusted code as a matter of routine.** `npm install`, `pip install`, `cargo build`, `paru -S`, and `docker run` against arbitrary images all execute third-party code, some of it with install-time hooks, on a machine that also holds the credentials worth stealing. This is not hypothetical — package-registry compromise is now a standard supply-chain technique, and the payload usually runs at install time, before any code is imported.

**The credentials on it are high-value.** SSH keys, cloud provider credentials in `~/.aws` / `~/.config/gcloud`, Kubernetes contexts, VPN configuration, and a shell history that maps the target's internal network.

**Its configuration is a persistence surface.** `~/.bashrc`, `~/.config/hypr/`, `~/.config/systemd/user/`, and shell init files are writable by the same user that runs `npm install`. Modifying one of them is the cheapest persistence available and produces no visible symptom.

**The existing default helps with one direction only.** Omarchy enables UFW with an inbound deny policy — good, and it is why Proposal A is a wrapper rather than a new default. But an inbound deny policy does not observe a reverse shell dialling out, a changed checksum on a shell init file, or a new setuid binary. Those are egress and integrity problems, not ingress ones.

*(The specific claim that Omarchy enables UFW with `default deny incoming` out of the box is taken from Omarchy's own documentation and my own install. If that is inaccurate or has changed, Proposal A's framing needs revisiting — please correct me in the thread.)*

The gap this RFC addresses is narrow: **give the user a straightforward way to manage the firewall they already have, close the password-authentication hole on the SSH path Omarchy already sets up, and make it possible — not mandatory — to run an endpoint sensor and route its alerts somewhere useful.**

---

## 3. Proposals

Each proposal below has its own heading anchor so it can be linked and argued with on its own.

### Proposal A — `omarchy firewall` CLI group

#### A. What changes

A new command group in the `omarchy` CLI that wraps UFW:

```bash
omarchy firewall status                      # active rules, formatted for humans
omarchy firewall allow <port> [--proto=tcp]  # allow a port, with an auto-generated comment
omarchy firewall deny <port>                 # remove that allowance
omarchy firewall reset                       # restore Omarchy's default policy (deny in, allow out)
```

No policy change. UFW's default posture stays exactly as Omarchy ships it; this only puts a discoverable front end on the four operations a developer performs.

#### A. Why

Opening port 3000 for a dev server currently means either remembering `ufw` syntax or, more commonly, disabling the firewall entirely because that is one command and the correct fix is three. The failure mode of a firewall that is inconvenient to adjust is a firewall that gets turned off. Making the narrow action easier than the broad one is the whole point.

The `--comment` behaviour matters more than it looks: rules added this way are self-documenting, so `omarchy firewall status` six months later tells the user *why* 5432 is open, which is the difference between a reviewable state and an accumulated one.

#### A. Cost and risk

- **Maintenance surface:** roughly one shell function per subcommand, plus argument validation. Small, but it is upstream code that has to be maintained and it duplicates something `ufw` already does.
- **Abstraction risk:** a wrapper that covers 80% of cases can make the other 20% harder to reason about, because users no longer see the underlying rule set. Mitigated by `status` printing the real `ufw status numbered` output rather than an invented format.
- **Naming:** if Omarchy ever moves off UFW to firewalld or plain nftables, the command name survives but the implementation does not. Arguably an argument for the wrapper, not against it.
- **The honest counter-argument:** `ufw allow 3000` is already short. If the maintainers' view is that the existing command is sufficient and the CLI surface should stay small, that is a reasonable position and this proposal should be dropped. It is the least important of the three.

#### A. How to revert

Delete the command group. It writes no state of its own; any rules a user created remain in UFW's own configuration and are managed with `ufw` as before. Nothing to migrate, nothing to clean up.

#### A. Status

**Not implemented.** No code exists for this in the reference repository — it is a design sketch, deliberately, until there is a signal that the shape is wanted.

---

### Proposal B — SSH daemon hardening drop-in

#### B. What changes

When the user runs the existing SSH setup path (the one that fetches and authorizes public keys from GitHub), also write `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf`:

```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
```

#### B. Why

The setup path already establishes key-based authentication. Leaving password authentication enabled afterwards means the weaker mechanism remains available on every interface the daemon listens on — LAN, Tailscale, or a public IP if the machine is ever exposed. Password authentication that nobody intends to use is exposure without benefit.

Setting this at the moment keys are installed is the right sequencing: the user has just proven they have working key auth, so the failure mode of turning off passwords is at its lowest.

#### B. Cost and risk

This is the proposal with real risk, and I want to be direct about it rather than describe it as a free win:

- **Lockout is possible.** If the key installation partly failed, or the user's only key lives on a machine they do not currently have, disabling password authentication locks them out of remote access. Physical or console access still works, but "still works" is cold comfort at 2am on a remote box.
- **Mitigation, and I think this is required, not optional:** validate before writing. Confirm at least one key is present in `authorized_keys`, run `sshd -t` against the new configuration, and refuse to write (or write and immediately roll back) if either check fails. A prompt showing exactly what is about to change is cheap and appropriate here.
- **`X11Forwarding no` is a behaviour change, not just a hardening one.** It is the correct default on a Wayland/Hyprland system, but anyone forwarding X over SSH into this box for a legacy tool will see it break with an unhelpful error. This line is separable from the rest and could be dropped if it is contentious.
- **`MaxAuthTries 3` interacts with agent-based auth.** Clients offering several keys from an agent can exhaust three attempts before reaching the right one. `MaxAuthTries 6` is a defensible compromise; I do not have strong feelings about the number.
- **It contradicts a "user-space only, no breaking changes" framing.** Writing to `/etc/ssh/sshd_config.d/` is neither. An earlier version of this material claimed both; that claim was wrong and is withdrawn.

#### B. How to revert

```bash
sudo rm /etc/ssh/sshd_config.d/99-omarchy-hardened.conf
sudo systemctl reload sshd
```

A single file, in a drop-in directory, with a numeric prefix that makes its precedence explicit. It never edits `sshd_config` itself, so the distribution's own file stays pristine and upgradeable. This is the main reason to prefer a drop-in over in-place editing.

#### B. Status

**Not implemented.** The reference repository contains no sshd configuration; this is a proposal for the upstream setup path.

---

### Proposal C — Optional EDR telemetry hook and incident bridge

#### C. What changes

Three separable pieces, all opt-in:

1. **A setup recipe** (`omarchy setup security edr` or similar) that helps a user get a corporate endpoint sensor running on Arch. In practice this is packaging guidance — most vendors ship `.rpm` or `.deb` and nothing else — plus enrollment steps per vendor.
2. **A status widget** for the bar showing whether a sensor is present and running. Read-only, no privileged access; it reports service state.
3. **A documented hook** so that a high-severity alert can launch a terminal with the local coding agent, pre-loaded with the alert context: the rule that fired, the process tree, listening sockets, and the affected path. The developer then decides what to do. Nothing is killed, blocked, or rolled back automatically.

#### C. Why

Two separate audiences, and it is worth keeping them apart:

**Users under corporate mandate.** A developer whose employer requires CrowdStrike, Defender, or SentinelOne on every endpoint currently cannot run Omarchy at work — not because the sensor is technically incompatible, but because nobody has written down how to get an RPM-packaged sensor onto Arch and enrolled. This is a documentation and packaging problem being solved privately, badly, by each person who hits it. Omarchy is the natural place to solve it once.

**Everyone else.** The gap identified in [§2](#2-problem-statement) — no visibility into egress or file integrity — is real regardless of employer. Wazuh is open source and self-hostable and closes some of it. But this is the weaker half of the argument, and I will not pretend otherwise: most individual users will not run a SIEM on their laptop, and a proposal that assumes they will is a proposal for a different audience.

The "hand the alert to the coding agent" piece is the part I think is genuinely novel and also the part I am least sure belongs upstream. An alert that says `T1059.004 — Unix Shell` means nothing to most developers. The same alert, opened in a terminal alongside the process tree and the offending path, with an agent that can explain it, is actionable. That is the bet. It may be the wrong bet.

#### C. Cost and risk

- **Vendor sensors are proprietary kernel-adjacent code.** Falcon, Defender, and SentinelOne ship binary agents. Recommending them sits badly with an Arch/free-software audience, and reasonably so. The counter is that Omarchy would recommend nothing — it would document how to run what the user is already required to run, and the only open-source path (Wazuh) would be the one it can actually test.
- **Rolling-release fragility.** Vendor sensors target enterprise LTS kernels. On Arch, a kernel bump can put a sensor into reduced-functionality mode with no notice. Any documentation Omarchy ships must say this loudly rather than implying "supported."
- **Maintenance burden is the real cost.** Five vendors' enrollment procedures change on their schedule, not Omarchy's. Documentation that goes stale is worse than no documentation, because it fails confidently. If this lands, it needs an owner, and that owner should probably be me rather than the Omarchy maintainers.
- **The Docker-based Wazuh stack listens locally.** Running the self-hosted option means the manager API and dashboard bind to ports on the workstation. In the reference implementation these are bound to `127.0.0.1` only (`127.0.0.1:9001`, `127.0.0.1:55000`, `127.0.0.1:1514`), but "zero listening ports" is not accurate for that configuration and I have removed that claim.
- **The alert watcher needs Docker socket access** in its current form, which is effectively root-equivalent. That is a design flaw in the reference implementation, not an inherent one — reading a log file does not require it — and it should be fixed before anything like this is proposed seriously.
- **Automated response is deliberately absent.** The hook opens a terminal. It does not kill processes or add firewall rules on its own. Autonomous containment on a developer machine will eventually kill the developer's own test process during a demo, and the trust cost of that is not recoverable.

#### C. How to revert

```bash
systemctl --user disable --now omarchy-sec-watcher.service
```

Remove the widget from the bar; remove the recipe. Since nothing is enabled by default, "reverting" for the overwhelming majority of users means nothing, because nothing was ever installed. Vendor sensors are removed by their own uninstallers, which is a property of those sensors and not something Omarchy should try to own.

#### C. Status

**Partially implemented out-of-tree.** Sensor detection, the alert watcher, the bar widget, and the agent bridge exist in the reference repository and are described in [§4](#4-what-already-exists-out-of-tree). None of it is in Omarchy, and none of it is proposed for inclusion as-is — the upstream ask is for the hook and the recipe, not for this code.

---

## 4. What already exists out-of-tree

For reviewers who want to look at running code before deciding whether the hooks are worth having. All of this lives in [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) and is installed by the user, separately from Omarchy.

| Component | What it actually does |
| :--- | :--- |
| `bin/omarchy-sec-detect` | Checks whether each of seven sensor families is running (Wazuh, Falcon, Cortex, SentinelOne, Defender, Falco/Tetragon, auditd) via `systemctl is-active`, `pgrep`, and file presence. Emits JSON. It reports service state; it does not integrate with vendor APIs. |
| `bin/omarchy-sec-watcher` | User systemd unit. Tails `alerts.json` from the Wazuh manager container, sends a desktop notification at rule level ≥ 7, and invokes the agent bridge at level ≥ 10. Currently requires Docker socket access — see [C. Cost and risk](#c-cost-and-risk). |
| `bin/omarchy-sec-agent` | Assembles live context (Wazuh API summary, recent alerts, `ss -tuln`, `ps aux`) into a prompt and opens the local coding agent with it. |
| `bin/omarchy-sec-wazuh-api` | Thin REST client for the Wazuh API — JWT auth with a short-lived cached token, plus `agents`, `sca`, `syscheck`, and alert queries. |
| `bin/omarchy-sec-onboard` | Interactive wizard printing vendor-specific extraction and enrollment steps, and running the vendor CLI when a token is supplied. |
| [`omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | Quickshell bar widget and popout panel showing sensor status. Separate repository, installed with `omarchy plugin add`. |
| `docker/single-node/` | Wazuh manager, indexer, and dashboard, all bound to `127.0.0.1`. |

Known rough edges, stated here rather than discovered by a reviewer: the watcher needs Docker socket access, described above. Nothing proposed upstream depends on it.

---

## 5. The DevSecOps pipeline behind this repo

This section describes what the pipeline **actually runs**, including what it does not catch. An earlier summary of this material described the pipeline as fully passing SAST, IaC, secrets, SCA, and DAST; that was not accurate, and the accurate version is below.

Two things run: `tests/run_tests.sh` locally, and `.github/workflows/security-ci.yml` on push and pull request to `main`. They overlap but are not the same set.

### 5.1 Local pipeline — `tests/run_tests.sh`

| # | Check | Tool | Blocks on failure? |
| :--- | :--- | :--- | :--- |
| 1 | Shell static analysis | `shellcheck` over `bin/` and `scripts/` | **Yes** — real failure, non-zero exit |
| 2 | Plugin and QML manifest validation | `omarchy plugin validate` | **Yes**, when the `omarchy` CLI is present |
| 3 | Secrets scanning | `gitleaks detect --no-git` | **Yes** |
| 4 | IaC misconfiguration | `trivy config docker/single-node` | **No** — see below |
| 5 | Detection engine smoke test | runs `bin/omarchy-sec-detect` | **Yes**, but see below |
| 6 | Dashboard reachability | `curl` against `https://localhost:9001` | **No** — see below |

Where it is weaker than it looks:

- **Checks 1–4 skip silently if the tool is not installed.** A skip is neither a pass nor a failure; the run still exits 0. On a machine without `shellcheck`, `gitleaks`, and `trivy`, four of the six checks evaporate and the pipeline reports success. This is the single biggest gap.
- **Check 4 cannot fail.** Trivy is invoked with `--exit-code 0`, so a HIGH or CRITICAL misconfiguration is found and then ignored, with output discarded. It is currently an informational scan reported as a gate.
- **Check 5 verifies that the script runs, not that a sensor exists.** `omarchy-sec-detect` exits 0 whether or not anything is protecting the machine.
- **Check 6 cannot fail.** Both branches of the conditional print PASS and increment the counter — if the dashboard is unreachable, the check reports "ready for deployment" and passes. Calling it DAST overstates it considerably; it is a reachability probe at best.
- **TruffleHog is named in the output text but never invoked.** Only Gitleaks runs.
- **There is no SCA.** No dependency or container image scanning exists in either pipeline, despite the CI workflow's name mentioning it.

### 5.2 CI pipeline — `.github/workflows/security-ci.yml`

Four steps on `ubuntu-latest`: ShellCheck (`ludeeus/action-shellcheck`, `scandir: ./bin`), Gitleaks, Semgrep (`p/security-audit`, `p/secrets`, `p/bash`), and Trivy in `config` mode against `docker/single-node`.

Differences from the local run that matter:

- **Semgrep runs only in CI**, never locally.
- **CI scans only `bin/`** — `scripts/` is covered locally but not in CI.
- **`omarchy plugin validate` never runs in CI**, since the Omarchy CLI is not available on a GitHub runner. The QML and manifest validation is therefore local-only, and only for contributors who have Omarchy installed.
- **Trivy does not block in CI either.** The action's default exit code is 0 and no override is set.

So the genuinely enforcing gates today are ShellCheck, Gitleaks, and Semgrep. Everything else is advisory, and the honest fix list is short: set a non-zero exit code on Trivy, make check 6 fail when the probe fails or drop it, make missing tools a hard failure in CI, and either wire up SCA or stop claiming it.

---

## 6. Open questions

Where I want the Omarchy maintainers' and community's judgment, roughly in the order I care about the answers:

1. **Is Proposal B's default change acceptable at all?** Disabling password authentication is the only place this RFC touches a security default, and it carries genuine lockout risk. Is a validated, prompted, drop-in-based change the right shape — or should hardening stay entirely opt-in through a separate command the user has to seek out?
2. **Does an EDR hook belong in Omarchy, or should it stay a third-party plugin forever?** The plugin system means Proposal C works fine out-of-tree. The argument for upstreaming is discoverability for corporate users; the argument against is that Omarchy would be endorsing proprietary sensors by documenting them. I lean toward "document the hook, endorse nothing," but this is the maintainers' call about the project's identity, not a technical question.
3. **Is `omarchy firewall` worth the CLI surface?** `ufw allow 3000` already works. If the answer is "the CLI stays small," Proposal A gets dropped and nothing is lost.
4. **How much should the coding agent be allowed to do?** This RFC deliberately stops at "open a terminal with context loaded." Is even that too much automation to have running on a developer machine? Is a desktop notification with a copyable command the right ceiling instead?
5. **What is the right behaviour on a rolling kernel?** If a `linux` package bump silently drops a vendor sensor into reduced-functionality mode, should anything warn the user? A pacman hook is possible but adds a whole class of maintenance nobody asked for.
6. **Should any of this be Omarchy's problem?** The most useful outcome of this thread may be "no — keep it a plugin, here is the one hook we would accept." That is a fine result and worth saying plainly if it is what people think.

Comments, objections, and flat rejections are all useful. Per-proposal replies are more useful than a verdict on the whole document.

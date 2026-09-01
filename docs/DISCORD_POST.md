# Discord post — `#omarchy-security`

Five messages, posted in order, one Discord message each.

## ⚠️ How to copy these

Each message below sits inside a grey code box. **Copy only what is INSIDE the
box — never the ``` fence lines themselves.** On GitHub, use the copy button in
the top-right corner of each box; it takes the contents and leaves the fence
behind. Pasting the fence is what puts stray ``` at the top and bottom of your
Discord message.

Message 3 is the exception and has its own instructions: it is one Discord
message assembled from three pieces, because the diagram needs to sit in a
Discord code block while the text around it must not.

## Why it is split this way

Discord caps a message at **2000 characters**, renders no Markdown tables, and
does render `#`/`##`/`###` headings, `**bold**`, `*italics*`, lists, inline
`code` and fenced code blocks. Every block below is under the cap and uses only
what Discord actually draws. The GitHub links auto-embed, so the last message
carries the link that matters.

**Emoji never go inside a code block.** They are not monospaced, so a single one
shifts every line after it — that is what broke the diagram the first time.

---

## 1️⃣ Message 1 — the hook

```
🛡️ **RFC: optional security hardening for Omarchy workstations**

Moss suggested I bring this here rather than open PRs cold, so — three small proposals, each one arguable on its own, none of them a package deal.

**The setup.** An Omarchy box runs untrusted code all day. `npm install`, `cargo build`, a `curl | sh` from a README. It also holds the good stuff: SSH keys, cloud tokens, `~/.aws`, session cookies. And `~/.config/hypr/` is a persistence surface — anything writing there runs at your next login.

Omarchy already ships `ufw` with inbound deny. That is the right default. It just does not say anything about egress, or about who rewrote your dotfiles at 3am.

**What I am NOT proposing:** 🚫 no bundled EDR · 🚫 no daemon on by default · 🚫 no telemetry · 🚫 no kernel modules · 🚫 no mandatory anything.

Three proposals, in the next message 👇
```

---

## 2️⃣ Message 2 — the three proposals

```
**🔥 A — `omarchy firewall` CLI group**

A thin wrapper over ufw: `status` / `allow <port>` / `deny <port>` / `reset`, with rules commented so you can tell later why port 3000 is open.

*Honest counter-argument:* `ufw allow 3000` already works and is one word shorter. This may not earn its CLI surface. I would rather hear that now than after a PR.

**🔐 B — sshd hardening drop-in**

`/etc/ssh/sshd_config.d/99-omarchy-hardened.conf` with `PasswordAuthentication no` + `KbdInteractiveAuthentication no`.

This is the only one that changes a default, and it is the one that can lock you out — so it only applies after `sshd -t` passes AND an authorized key is present. `MaxAuthTries` and `X11Forwarding` are separable; argue them individually.

**🤖 C — EDR telemetry hook for `omarchy-agent`**

Omarchy already does great post-mortem (`omarchy agent crash <pid>`). This adds the live counterpart: an opt-in hook so a high-severity event can reach the agent for triage.

Status: A and B are **not implemented**. C exists out-of-tree and needs Docker socket access today, which is root-equivalent — that is a real cost, not a footnote.
```

---

## 3️⃣ Message 3 — the flow

This one is **one Discord message built from two pieces**. Do not paste them as a
single blob — the diagram has to sit inside a Discord code block or the columns
collapse. The diagram deliberately contains **no emoji**: emoji are not
monospaced, and one inside a code block shifts every line after it.

**Piece 1 — type this as normal text:**

> **⚙️ How the out-of-tree piece actually works**
>
> Nothing below is proposed for core Omarchy. It is what I built to test whether the hooks are worth having.

**Piece 2 — in the same message, type three backticks, press Shift+Enter, paste
the block below, press Shift+Enter, type three backticks again:**

```
   sensors on the box            you                 optional
  +------------------+     +---------------+   +----------------+
  | Wazuh   Falcon   |     |    the bar    |   | corporate      |
  | Cortex  S1       |--+->| [#] protected |   | SOC / MDR      |
  | Defender  Falco  |  |  +---------------+   +----------------+
  | auditd           |  |                              ^
  +------------------+  |                              |
           |            |                     outbound TLS only
           v            |                              |
  +------------------+  |                              |
  |   omarchy-sec    |  +------------------------------+
  |     -detect      |     (vendor agent's own channel)
  +------------------+
           |
           |  rule level >= 10
           v
  +------------------+
  |  omarchy-agent   |   triage, in your terminal
  +------------------+

  every port of the self-hosted stack binds 127.0.0.1 - nothing on the LAN
```

**Piece 3 — back to normal text, after the closing backticks:**

> Three states, and the third one matters: 🟢 protected · 🔴 no sensor running · ⚪ **unknown**. A security indicator that says "unprotected" when it simply could not look is a false alarm, so it says it does not know instead.

## 4️⃣ Message 4 — the part nobody posts

```
**🔍 What I got wrong, before someone finds it**

I audited my own repo before bringing this here, and the pipeline I was bragging about was not doing its job:

• The dashboard check printed **PASS in both branches** — an unreachable console reported "ready for deployment". It could not fail.
• Trivy ran with `--exit-code 0`. A CRITICAL misconfiguration still printed "passed security audit".
• The header said "Gitleaks & TruffleHog". Only gitleaks was ever invoked.
• The compose published 6 ports on `0.0.0.0` — manager and indexer offered to the whole LAN — while my README claimed "zero inbound listening ports". 🤦
• It shipped the wazuh-docker demo passwords, and `setup.sh` printed one to the terminal on every run.
• The API client cached its token at `/tmp/.wazuh_api_token`. Shared dir, predictable path.

All fixed, all in the git history rather than quietly rewritten. I am posting it because a security proposal from someone who has not audited their own work is worth nothing.
```

---

## 5️⃣ Message 5 — the ask (this one carries the link)

```
**📄 Full RFC** — each proposal has its own anchor so you can argue one without the others:
https://github.com/MAXI8594/omarchy-sec/blob/main/docs/PROPOSAL.md

**🧩 Bar widget** (separate repo, marketplace submission pending):
https://github.com/MAXI8594/omarchy-sec-plugin

**❓ The questions I actually want answered:**

1. Is A worth a CLI at all, or is `ufw` already the answer?
2. If B ships, does it belong on by default or behind `omarchy setup security sshd`?
3. Should any of this be Omarchy's problem, or does it belong entirely out-of-tree?

I would rather kill a proposal here than land a PR nobody wanted. 🙏
```

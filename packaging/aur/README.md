# Publishing `omarchy-sec` to the AUR

The AUR package ships the system components: the seven `bin/` CLIs and the
`omarchy-sec-watcher` **user** service. The QML widget lives in a separate repo
and is distributed through the Omarchy Marketplace.

This package is not a convenience — it is the only way to make the bar widget
work. Following a marketplace security review, the widget only executes
`/usr/bin/omarchy-sec-detect` and `/usr/bin/omarchy-sec`, and only after
verifying each is a regular file owned by root with no group/other write bit
(see `validationArgs` in the plugin's `WazuhService.qml`). A checkout installed
via `install.sh` puts the binaries in `~/.local/bin` instead, which the widget
now refuses on purpose — that path is user-writable, so validating it and then
executing it would be check-then-execute. Only this package, built and
installed with `makepkg -si` (root), satisfies the widget's trust check.

**Current release is `1.0.1`. Do not tag or package `1.0.0`** — its tag
predates a command-injection fix (`be1660f`) that shipped in `1.0.1`
(`3b953a7`). `1.0.0` is superseded, not an alternative version.

## Status: blocked upstream, not on us

As of 2026-09-01 the AUR has **paused new account registration** while it deals
with a wave of automated account creation (HTTP 503 on the register page). The
package cannot be published until that reopens and an account exists.

The notice asks explicitly not to script retries against that page. Do not add a
polling job for it. Announcements go to
[aur-general](https://lists.archlinux.org/mailman3/lists/aur-general.lists.archlinux.org/)
and the [Arch news feed](https://archlinux.org/news/); watch those instead.

Nothing here is waiting on work. `PKGBUILD` and `.SRCINFO` are final for 1.0.1,
verified in sync, and the package has been built and installed on a real machine
end to end.

### When registration reopens

1. Register at <https://aur.archlinux.org/register>, then paste the SSH public
   key into **My Account → SSH Public Key**. The key must match the fingerprint
   you registered; a comment change does not alter it.
2. Confirm the AUR recognises you before touching git:

       ssh aur@aur.archlinux.org help

   `Permission denied (publickey)` means the key is not registered yet.
3. Publish. The AUR uses `master`, not `main`, and rejects a push whose
   `.SRCINFO` disagrees with the `PKGBUILD`:

       git clone ssh://aur@aur.archlinux.org/omarchy-sec.git /tmp/aur-omarchy-sec
       cp PKGBUILD .SRCINFO omarchy-sec.install /tmp/aur-omarchy-sec/
       cd /tmp/aur-omarchy-sec
       makepkg --printsrcinfo > .SRCINFO      # regenerate rather than trust the copy
       git add PKGBUILD .SRCINFO omarchy-sec.install
       git commit -m "Initial import: omarchy-sec 1.0.1"
       git push -u origin master

The name `omarchy-sec` was unclaimed when this was written
(`https://aur.archlinux.org/rpc/v5/info?arg[]=omarchy-sec` returned zero
results). Check again before importing.


## namcap output, and why the four warnings stand

`namcap` on the `PKGBUILD` reports nothing. On the built package it reports four:

    omarchy-sec W: Dependency included, but may not be needed ('curl')
    omarchy-sec W: Dependency included, but may not be needed ('inetutils')
    omarchy-sec W: Dependency included, but may not be needed ('jq')
    omarchy-sec W: Dependency included, but may not be needed ('libnotify')

All four are false positives, and the reason is structural rather than a
judgement call: namcap infers dependencies from the dynamic linkage of ELF
binaries. Every file this package ships is a bash script — verified with `file`
on the built package, seven scripts and zero ELF objects — so there is no
linkage to read and namcap cannot see a single call. It is not disagreeing with
the dependency list; it has no way to evaluate it.

Each one is invoked by name in the shipped scripts:

| Package | Binary | Uses | Where |
| :--- | :--- | --: | :--- |
| `curl` | `curl` | 5 | `omarchy-sec-wazuh-api` |
| `jq` | `jq` | 19 | `omarchy-sec-agent`, `omarchy-sec-wazuh-api`, `omarchy-sec-watcher` |
| `libnotify` | `notify-send` | 5 | `omarchy-sec-watcher`, `omarchy-sec-agent` |
| `inetutils` | `hostname` | 2 | `omarchy-sec-onboard`, `omarchy-sec-agent` |

Dropping any of them breaks a path at runtime with a "command not found" the
user did not ask for. They stay.

### Running namcap on this machine

`namcap` is a bash wrapper that calls `python3 -m namcap`, and `python` here
resolves to mise's interpreter, which does not have the module. Run it with the
system interpreter first on PATH:

    PATH=/usr/bin:/bin namcap packaging/aur/PKGBUILD
    PATH=/usr/bin:/bin namcap omarchy-sec-1.0.1-1-any.pkg.tar.zst

## Layout

| File | Purpose |
|---|---|
| `PKGBUILD` | Build recipe. `pkgver` must match a pushed git tag `v$pkgver`. |
| `omarchy-sec.install` | Post-install hint on enabling the user service. |
| `.SRCINFO` | Generated metadata — the AUR rejects pushes without it. |

## 1. Tag the release first

`source` pins `git+…#tag=v$pkgver`, so the tag has to exist before anyone can build.
`v1.0.1` is already tagged and pushed; a future bump follows the same pattern:

```bash
git tag -a v1.0.1 -m "omarchy-sec 1.0.1"
git push origin v1.0.1
```

## 2. Verify locally

```bash
cd packaging/aur
makepkg --printsrcinfo > .SRCINFO   # regenerate after ANY PKGBUILD edit
namcap PKGBUILD
makepkg -si                         # builds + installs; needs a real terminal for sudo
namcap ../../*.pkg.tar.zst
```

## 3. Push to the AUR

You need an SSH key registered at https://aur.archlinux.org/account/ (`~/.ssh/aur`
with a matching `Host aur.archlinux.org` block in `~/.ssh/config`).

```bash
git clone ssh://aur@aur.archlinux.org/omarchy-sec.git /tmp/aur-omarchy-sec
cd /tmp/aur-omarchy-sec
cp ~/Projects/omarchy-sec/packaging/aur/{PKGBUILD,.SRCINFO,omarchy-sec.install} .
git add PKGBUILD .SRCINFO omarchy-sec.install
git commit -m "Initial import: omarchy-sec 1.0.1"
git push
```

The AUR repo is standalone — only these three files belong in it, never the
project source. An empty clone is normal for a package name nobody has taken yet.

## 4. Releasing an update

1. Bump `pkgver` (and reset `pkgrel=1`), or bump `pkgrel` alone for packaging-only fixes.
2. Tag and push the new `v$pkgver` in the source repo.
3. `makepkg --printsrcinfo > .SRCINFO`.
4. Copy both files to the AUR clone, commit, push.

## After installing

```bash
systemctl --user daemon-reload
systemctl --user enable --now omarchy-sec-watcher.service
journalctl --user -u omarchy-sec-watcher -f
```

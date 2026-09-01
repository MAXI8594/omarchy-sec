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

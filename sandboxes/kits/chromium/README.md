# chromium

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox **headless Chromium** (Debian's `chromium` package), for screenshots and
Chrome DevTools Protocol scripting.

```text
chromium/
├── chromium.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── chromium-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no dockerfile, so nothing is built. Like the
[`psql`](../psql) kit, it installs apt packages with a `lifecycle@1` install
hook run as root at sandbox create, because apt packages need the composed
base's dpkg database and cannot travel in an overlay. The apt hosts
(`deb.debian.org`, `dhi.io`) are open only during that install phase.

## What it installs

| Package | Why |
|---|---|
| `chromium` | the browser, at `/usr/bin/chromium` |
| `fonts-liberation` | the base image ships no fonts; these are metric-compatible with Arial, Times and Courier |

Installed with `--no-install-recommends`, which skips Chromium's desktop
recommends (udev, upower, a notification daemon, printing). No runtime network
grant: what pages the browser may load is the project's policy.

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/chromium
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick this
up. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
chromium --version
chromium --headless --no-sandbox --screenshot=/tmp/x.png about:blank
```

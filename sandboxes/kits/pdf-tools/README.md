# pdf-tools

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox **command-line tools for PDFs and SVGs**: poppler's `pdftotext` and
`pdftoppm`, and librsvg's `rsvg-convert`.

```text
pdf-tools/
├── pdf-tools.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── pdf-tools-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no dockerfile, so nothing is built. Like the
[`psql`](../psql) kit, it installs apt packages with a `lifecycle@1` install
hook run as root at sandbox create, because apt packages need the composed
base's dpkg database and cannot travel in an overlay. The apt hosts
(`deb.debian.org`, `dhi.io`) are open only during that install phase.

## What it installs

| Package | Commands |
|---|---|
| `poppler-utils` | `pdftotext`, `pdftoppm`, `pdfinfo`, `pdfimages`, ... |
| `librsvg2-bin` | `rsvg-convert` (SVG to PNG/PDF) |

No runtime network grant; the tools work on local files.

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/pdf-tools
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick this
up. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
pdftotext -v
rsvg-convert --version
```

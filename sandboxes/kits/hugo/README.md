# hugo

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox **Hugo, extended edition**, at a version
each sandbox pins for itself.

```text
hugo/
├── hugo.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── hugo.dockerfile    # the overlay recipe, paired by filename stem
├── hugo-context.md    # the agent-context body
└── README.md
```

## What it installs

The official `hugo_extended_<version>_linux-<arch>.tar.gz` from
[gohugoio/hugo releases](https://github.com/gohugoio/hugo/releases), checked
against that release's `hugo_<version>_checksums.txt`, shipped as an overlay at
`/usr/local/bin/hugo`. The build also checks that `hugo version` reports the
requested version and the extended edition. The download happens on the
builder, so sandbox creation fetches nothing.

Debian's apt `hugo` is 0.131 on trixie, too old for the sites here, which is
why this kit does not use apt.

## Use

`version` is a **required** argument, so every sandbox states the Hugo its
site is built with. In an `sbxenv.yaml`:

```yaml
kits:
  - source: /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/hugo
    args:
      version: "0.168.0"
```

Quote the version so YAML keeps it a string. On the command line:

```console
sbx run claude --kit ./hugo --kit-arg hugo.version=0.168.0 .
```

Current pins: lincolnmullen.com uses 0.168.0 (its `.mise.toml`);
legal-modernism uses 0.161.1 (its `website/Dockerfile`). When a site bumps
Hugo, bump the pin in its `sbxenv.yaml` and recreate the sandbox.

## Verify inside a sandbox

```bash
hugo version    # hugo v0.168.0-...+extended linux/arm64 ...
```

To check the descriptor and build the overlay without `sbx`, from inside this
directory:

```console
docker buildx build . -f hugo.yaml --build-arg version=0.168.0 --output type=cacheonly
docker buildx build . -f hugo.dockerfile --build-arg HUGO_VERSION=0.168.0
```

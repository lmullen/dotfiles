## Tools via mise

Language toolchains in this sandbox (Go, Node, Hugo, ...) are managed by
[mise](https://mise.jdx.dev), not apt. Each project lists the tools it needs
in its own `mise.toml`, `.mise.toml` or `.tool-versions`; `mise ls` shows
what is installed and which config asked for it.

- `~/.local/share/mise/shims` is on PATH in every shell, including your Bash
  tool's. Each shim picks the version for the current directory when it runs,
  and installs a pinned version that is missing on first use.
- If a tool is missing, run `mise install` in the project. To add one the
  project needs, add it to the project's mise config (`mise use
  <tool>@<version>`) so the change is committed with the project. Do not
  install a toolchain with apt or a curl script.
- `go install` puts binaries in `~/go/bin`, which is not on PATH.
- Network policy allows mise's GitHub, nodejs.org and dl.google.com
  downloads, plus proxy.golang.org, sum.golang.org and registry.npmjs.org. If
  `mise install` is blocked, the proxy error names the host; tell the user
  rather than working around it.

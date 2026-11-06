# claude-light-theme

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit (schemaVersion 3,
`kind: mixin`) that sets Claude Code's theme to `light`.

Claude Code's `auto` theme tries to read the terminal background from
`COLORFGBG` or an OSC 11 query. Inside a sandbox neither reliably reaches
Claude, so it renders dark in a light Ghostty. This kit's install hook merges
`"theme": "light"` into `/home/agent/.claude.json` with `jq`, leaving every
other key alone.

```console
sbx run claude --kit ./claude-light-theme .
```

## Caveats

- The `theme` key in `~/.claude.json` is not confirmed against the official
  docs. If the sandbox still comes up dark, run `/theme` once in a session,
  pick Light, and check what changed in `~/.claude.json` and
  `~/.claude/settings.json` (which has an undocumented `themeId`); then adjust
  the hook to write that.
- Claude Code manages `~/.claude.json` itself and could overwrite the value.
- Needs Docker Sandboxes v0.51.0 or later, like the other kits here.

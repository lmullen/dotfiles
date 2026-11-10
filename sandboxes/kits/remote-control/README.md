# remote-control

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit (schemaVersion 3,
`kind: mixin`) that turns on Claude Code's **Remote Control at startup**, so
every Claude session in the sandbox can be followed and driven from claude.ai
or the Claude app without running `/remote-control` first.

Its install hook merges `"remoteControlAtStartup": true` into
`/home/agent/.claude/settings.json` with `jq`, leaving every other key alone.
This is the key `/config` → "Enable Remote Control for all sessions" writes.
It must live at user scope: Claude Code ignores it in a project's
`.claude/settings.json` or `.claude/settings.local.json`.

```console
sbx run claude --kit ./remote-control .
```

## Verify inside a sandbox

```bash
jq .remoteControlAtStartup ~/.claude/settings.json   # true
```

A new Claude session should show the Remote Control link at startup. To turn it
off for one sandbox, set the key to `false` with `/config`.

Kits apply when a sandbox is created, so an existing sandbox must be recreated
to pick this up. Needs Docker Sandboxes v0.51.0 or later, like the other kits
here.

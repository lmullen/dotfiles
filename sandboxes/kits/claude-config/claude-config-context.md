## Claude Code configuration

This sandbox's user settings (`~/.claude/settings.json`, `~/.claude.json`)
were set when it was created:

- **Status line:** /usr/local/bin/claude-statusline, registered under
  `statusLine`. It shows the sandbox name, the model, the project and git
  branch of the checkout being edited (a linked worktree shows as
  `<project>/<branch>`), the 5-hour session usage with the time until it
  resets, and how full the context window is. A project's own `.claude/settings.json` can override it with a
  `statusLine` of its own.
- **Remote Control** starts with every session (`remoteControlAtStartup`).
- **Theme** is `light`.

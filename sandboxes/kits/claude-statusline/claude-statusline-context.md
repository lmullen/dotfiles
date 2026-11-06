## Status line

This sandbox renders a custom Claude Code status line via
/usr/local/bin/claude-statusline, registered under `statusLine` in
~/.claude/settings.json. It shows the sandbox name, the model, the project
and git branch of the checkout being edited (a linked worktree shows as
`<project>/<branch>`), and the 5-hour session usage with the time until it
resets. A project's own `.claude/settings.json` can override it with a
`statusLine` of its own.

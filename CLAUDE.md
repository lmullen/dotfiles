# CLAUDE.md

My dotfiles, and the configuration for the sandboxes Claude Code runs in
(`sandboxes/`). See `README.md`, and the README in each directory under
`sandboxes/`.

## Git and GitHub

The rules for working with Git and GitHub come from the lmullen-agent kit,
not from this file. This repository is where they are written:
`sandboxes/kits/lmullen-agent/lmullen-agent-context.md` is the one source,
for every repository, in both the Docker sandboxes and the Claude Code cloud
environments. To change a rule, change that file. Keep facts about a single
repository out of it; those belong in that repository's own CLAUDE.md.

Facts about this repository:

- **No project board.** Issues here are not added to any GitHub project.
- **A change to the rules reaches a sandbox only when it is recreated**, and
  a cloud environment only when its cache is rebuilt. Say so in the pull
  request when it matters.

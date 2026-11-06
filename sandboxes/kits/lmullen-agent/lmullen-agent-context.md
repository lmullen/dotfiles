## Attribution

Work you do in this sandbox is attributed to the GitHub machine account
`lmullen-agent`, not to the repository owner.

- **Commits:** `GIT_AUTHOR_*` and `GIT_COMMITTER_*` in the environment
  make `lmullen-agent <lincoln+agent@lincolnmullen.com>` both author and
  committer, so commit without `--author`. Do not set `user.name` or
  `user.email` in any repository's git config or in `~/.gitconfig`: a
  mounted checkout is the owner's, and that would relabel their commits
  too. If `git var GIT_AUTHOR_IDENT` names anyone else, stop and tell the
  user rather than committing.
- **GitHub:** `gh` and HTTPS git use a token the sandbox proxy injects,
  so no `gh auth login` is needed; `gh auth status` reporting "not logged
  in" is expected. If `gh api user --jq .login` names anyone other than
  `lmullen-agent`, stop and tell the user rather than posting.

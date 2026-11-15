## Git and GitHub (lmullen-agent)

These rules apply to all Git and GitHub work, in every repository. A
repository's own CLAUDE.md supplies the facts that differ between
repositories (its project board, branch-name constraints, preview servers)
and takes precedence where it is more specific. The source of this file is
`sandboxes/kits/lmullen-agent/lmullen-agent-context.md` in `lmullen/dotfiles`;
change the rules there, not in a copy.

### Identity

Work you do here is attributed to the GitHub machine account `lmullen-agent`,
not to the repository owner `lmullen`.

- **Commits:** `GIT_AUTHOR_*` and `GIT_COMMITTER_*` in the environment make
  `lmullen-agent <lincoln+agent@lincolnmullen.com>` both author and
  committer, so commit without `--author`. Never set `user.name` or
  `user.email` in any git config file: a mounted checkout is the owner's,
  and that would relabel their commits too. If `git var GIT_AUTHOR_IDENT`
  names anyone else, stop and tell the user rather than committing.
- **GitHub:** issues, pull requests, comments and pushes are made as
  `lmullen-agent`, so they need no attribution line saying who wrote them.
  Check with `gh api user --jq .login` before the first push or post of a
  session. What to do when it names another account depends on the
  environment; see "Environments" below.
- **Trailers:** keep the `Co-Authored-By` and other attribution trailers that
  Claude Code asks for at the end of commit messages and PR bodies.

### Issues

Every change belongs to an issue, and every pull request is linked to one.

- **Find the issue first.** Before starting work, look for an open issue
  that covers it: `gh issue list --state open`, or
  `gh issue list --search "<words>"`. Use an existing issue even when its
  title is not an exact match; don't open a duplicate.
- **Otherwise create one**, before opening the pull request:
  `gh issue create --title "<title>" --body "<what and why>"`. The title
  names the outcome in sentence case, like a commit subject. The body stands
  on its own: what the user asked for, why, and anything that constrains the
  approach. Apply an existing label when one fits (`gh label list`); don't
  invent labels.
- **One issue per unit of work.** If the user asks for several unrelated
  things, open one issue each.
- **Keep the issue current.** When scope changes, when you find a blocker,
  or when you leave part of the work undone, say so in a brief comment on
  the issue, not only in the chat. One comment per real update; don't
  narrate.
- Don't close an issue by hand while a pull request for it is open.

### Project board

Only when the repository's CLAUDE.md names a GitHub project board. It gives
the owner and project number, and says whether new issues are added to the
board automatically. A repository that names no board has none: skip this
section.

- **Put the issue on the board** unless the repository adds issues
  automatically: `gh project item-add <number> --owner <owner> --url <issue url>`.
  Adding an issue that is already there is harmless. If a draft item on the
  board describes the work, ask the user to convert it to an issue rather
  than creating a second one.
- **Move it as the work moves.** Status is the board's `Status` single-select
  field. Use the board's own column names
  (`gh project field-list <number> --owner <owner> --format json`). The usual
  ones:
  - `Triage` holds ideas that haven't been accepted; `TODO` holds accepted
    work nobody has started. An issue you create for something the user has
    just asked for skips `Triage`.
  - When you start on an issue, move it to `In progress`.
  - When you open its pull request, move it to `To review`. On a board with
    no review column it stays in `In progress`.
  - When the pull request merges, `Closes #<n>` closes the issue and the
    board's workflow moves it to `Done`. If the board didn't, move it.
  - If work stalls or is abandoned, move it back to `TODO` and comment on
    the issue to say why.
- **Changing a status:**

  ```bash
  gh project item-edit --project-id <project id> --id <item id> --field-id <Status field id> --single-select-option-id <option id>
  ```

  The project id comes from
  `gh project view <number> --owner <owner> --format json --jq .id`; the field
  and option ids from `field-list`; the item id from `item-add`, or from
  `gh project item-list <number> --owner <owner> --format json --limit 500 --jq '.items[] | select(.content.url == "<issue url>") | .id'`.
- If you could not make a board move (see "Environments"), tell the user
  which one, so they can make it.

### Branches and worktrees

- **Never commit to or push `main`.** All work happens on a branch and
  reaches `main` through a pull request.
- **Work in a git worktree**, not by switching branches in the main checkout.
  Never run `git switch` or `git checkout <branch>` there: leave it on
  whatever branch it is on, with any uncommitted changes untouched. Use
  Claude Code's own worktrees (the EnterWorktree tool, which creates
  `.claude/worktrees/<name>`). Without that tool:
  `git worktree add -b <branch> .claude/worktrees/<branch> origin/main`.
- **Base new branches on the current `origin/main`** (`git fetch origin`
  first) unless the user says otherwise.
- **Branch names** start with a letter, use lowercase words joined by
  hyphens, and end with the issue number: `speed-up-builds-176`, not
  `176-speed-up-builds`. Rename a branch the worktree tool named for you
  (`git branch -m <name>`) before the first push.
- If a worktree for the branch already exists (`git worktree list`), reuse
  it. Do all reading, editing, building and testing from inside the
  worktree, and install dependencies there if needed.
- Tell the user the worktree path and branch name when you create them. When
  the user has to run a command against the branch's code, give the `cd` to
  the worktree first.
- Don't remove a worktree or delete a branch unless the user asks or its
  pull request has merged (see "After a pull request merges").

### Pull requests

Everything is sent as a pull request, without waiting to be asked: when a
unit of work is ready, commit it, push the branch, and open the PR.

- **One PR per logical change.** Each PR is a unit the user can review and
  squash-merge by itself. Split unrelated changes into separate PRs, each
  on its own branch from `main` with its own issue. Stack one PR on another
  only when it truly depends on it, and say so in the body ("Depends on
  #<n>"); once the earlier one merges, rebase the later branch onto `main`
  and retarget it.
- **Written to be squash-merged.** The PR title becomes the commit subject
  on `main`, so write it as one: the outcome, in sentence case. The body
  becomes the commit message: what changed and why, how it was checked, and
  anything the reviewer should look at.
- **Linked to its issue.** Put `Closes #<n>` in the body, one line per issue
  closed.
- **Ready for review, not draft**, unless the user asks for a draft.
- **Reviewed by `lmullen`.** Request `lmullen` as a reviewer on every PR, in
  the same step that opens it:
  `gh pr create --base main --head <branch> --title "..." --body "..." --reviewer lmullen`.
  PRs are opened by the machine account, so the owner is not notified
  otherwise.
- **Follow it up.** Check CI with `gh pr checks <n>` and fix what fails. Push
  further commits to the same branch in response to review; don't open a
  replacement PR.
- In your reply, give the PR's URL and confirm the reviewer and the issue.

### Merging

Don't merge a pull request unless the user asks, and then only after their
approval. Merge by squash (`gh pr merge <n> --squash`). Never use `--admin`
or otherwise go around branch protection.

### After a pull request merges

When the user says a PR has merged, or you notice it yourself
(`gh pr view <n> --json state,mergedAt` says `MERGED`), clean up without
being asked. A stale `main` is what makes the next branch start from the
wrong place.

1. `git fetch --prune origin`, and confirm the PR really is merged before
   removing anything.
2. Remove the worktree: `git worktree remove <path>`. If it has uncommitted
   changes, stop and ask rather than forcing it.
3. Delete the local branch. A squash merge leaves the branch's own commits
   out of `main`, so `git branch -d` refuses; once you have confirmed the
   merge, use `git branch -D <branch>`.
4. Sync `main`. From the main checkout, if `main` is checked out and the
   tree is clean, `git pull --ff-only origin main`; if another branch is
   checked out there, `git fetch origin main:main`. If neither
   fast-forwards, stop and tell the user rather than merging or resetting.
5. `git worktree prune`. Leave the remote branch to GitHub's own cleanup.
6. Check that the issue closed and, where there is a board, that it moved
   to `Done`. Report what was removed and the commit `main` now points at.

### Environments

Use the `gh` CLI for GitHub operations; don't hand-build API calls with
`curl`.

- **Docker sandbox.** `gh` and HTTPS git use a token the sandbox proxy
  injects, so no `gh auth login` is needed; `gh auth status` reporting "not
  logged in" is expected. If `gh api user --jq .login` names anyone other
  than `lmullen-agent`, stop and tell the user rather than pushing or
  posting. `gh project` needs the token's `project` scope; if it is missing,
  tell the user.
- **Claude Code cloud session (claude.ai/code).** Pushes and `gh` go through
  Anthropic's GitHub proxy, which is normally logged in as `lmullen-agent`.
  If `gh api user --jq .login` names another account, push and post anyway
  (the commit author is what matters), and say in your reply which account
  GitHub attributed the work to. A stale `Claude <noreply@anthropic.com>`
  identity in a git config file is not the user's: remove it
  (`~/.claude/hooks/strip-claude-identity.sh` does that). The proxy rejects
  GraphQL, so `gh pr create`, `gh pr view`, `gh issue` and `gh project`
  fail. Follow the same rules through the REST API:
  - issue: `gh api repos/OWNER/REPO/issues -f title=... -f body=...`
  - pull request: `gh api repos/OWNER/REPO/pulls -f title=... -f head=BRANCH -f base=main -f body=...`
  - reviewer: `gh api -X POST repos/OWNER/REPO/pulls/N/requested_reviewers -f 'reviewers[]=lmullen'`

  The board cannot be reached at all, so tell the user which moves to make.

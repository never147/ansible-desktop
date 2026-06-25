---
description: >
  How to fold `fixup!` commits into their targets and finish a branch for
  merge in this environment. Load this when cleaning up branch history
  before merge, or whenever you need an interactive-style rebase. Covers
  the non-interactive autosquash workaround (interactive rebase is blocked
  here), the empty-diff safety check, and the force-push / merge convention.
---

# Tidying branch history (autosquash) and finishing a branch

This pairs with `[[git-commit]]` (which decides *when* a change is a `fixup!`
vs a new commit) and `[[monitor-ci]]` (driving the resulting CI to green).

## Interactive rebase is blocked — use non-interactive autosquash

`git rebase -i` (and `git add -i`) cannot prompt in this environment. To
autosquash `fixup!` commits without an interactive editor, neutralize both
editors so git auto-accepts the autosquash-arranged todo list:

```bash
base=$(git merge-base HEAD main)
GIT_SEQUENCE_EDITOR=true GIT_EDITOR=true git rebase --autosquash -i "$base"
```

`true` exits 0 without modifying the todo file, so the rebase proceeds with the
fixups already reordered next to (and marked to squash into) their targets.

## Verify the rewrite changed no content

A rebase can introduce subtle changes (or hit a silent conflict resolution).
Before pushing, confirm the tree is byte-identical to the pre-rebase head:

```bash
git diff <old-head> HEAD   # MUST be empty
```

If this prints anything, stop and investigate — the squash altered content it
shouldn't have. (Capture `<old-head>` from `git rev-parse HEAD` *before* the
rebase, or read it from the reflog: `git reflog`.)

## Force-push with lease

After rewriting history, push with lease (never a bare `--force`, which can
clobber a teammate's push):

```bash
git push --force-with-lease
```

A force-push **re-triggers CI**. Wait for the new run to go green before
merging — see `[[monitor-ci]]`.

## Merge convention

Merge with a merge commit, preserving the individual commits:

```bash
env -u GH_TOKEN gh pr merge <n> --merge
```

Do **not** squash-merge — `main`'s history keeps the curated per-commit history
behind "Merge pull request #…" commits, and squashing would collapse the
careful split you just made.

## Common mistakes to avoid

- **Running `git rebase -i` without neutralizing the editor** — it hangs/aborts
  with no way to interact. Always set `GIT_SEQUENCE_EDITOR=true GIT_EDITOR=true`.
- **Skipping the empty-diff check** — you can ship an unintended change hidden
  inside a "harmless" squash.
- **`git push --force`** — use `--force-with-lease`.
- **Squash-merging** — collapses the individual commits; use `--merge`.
- **Merging before the post-force-push CI finishes** — you may be looking at
  stale green checks from the previous head.

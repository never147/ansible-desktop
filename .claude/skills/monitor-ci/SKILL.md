---
description: >
  How to push changes and drive a pull request's CI to green for this
  repository using the gh CLI. Load this whenever monitoring PR checks,
  diagnosing a failed build, or merging. Covers handling gh
  authentication failures, the watch/inspect loop, reading the Ansible
  play recap, and the merge convention.
---

# Monitoring CI and merging PRs

## Handle gh authentication failures — don't work around them silently

Run `gh` commands normally:

```bash
gh pr checks <n>
```

If a `gh` call fails with `HTTP 401 Bad credentials`, do **not** silently work
around it. A `GH_TOKEN` environment variable is likely set to a stale or
otherwise invalid token that overrides the working credentials `gh` would find
in the keyring. Stop and tell the user their `GH_TOKEN` looks invalid so they
can fix their environment (re-auth or unset it) — that is the real fix.

Only if the user asks you to bypass it should you fall back to the keyring token
by unsetting the variable for a single command:

```bash
env -u GH_TOKEN gh pr checks <n>
```

## The loop: push → watch → inspect → fix

1. **Push** your branch (`git push`, or `git push --force-with-lease` after a
   rebase — see `[[tidy-branch-history]]`).
2. **Watch** the checks to completion (run in the background):
   ```bash
   gh pr checks <n> --watch --interval 30
   ```
3. On failure, **inspect** the failing run's log:
   ```bash
   gh pr checks <n>          # find the failed run's URL/id
   gh run view <run-id> --log-failed
   ```
4. In the log, read the Ansible **play recap** (`ok= changed= failed=`) and the
   `Task failed … Origin:` line — it gives the exact `tasks/*.yml:line` of the
   failing task. Fix, push, repeat.

## What CI runs

The `build` job (`.github/workflows/ansible-test.yml`) fabricates a throwaway
`personal.yml`, runs `./bin/bootstrap.sh`, then:

```bash
./bin/apply.sh \
  --skip-tags "docker,shorewall,shorewall_config,hid-apple,power-save,snaps"
```

Notes:
- `os_update` defaults to `false`, so CI does **not** do a full dist-upgrade.
- The `apt_update` tag is **not** skipped, so the apt cache refresh runs (see
  `[[apt-repos]]`).
- A separate `run-lint` job runs the super-linter (YAML / GITLEAKS / JSCPD /
  GITHUB_ACTIONS). Plus CodeQL, CodeRabbit, GitGuardian.

## When a module is fundamentally broken in CI

If a task fails because of an upstream module bug that you can't fix from this
repository (e.g. the `community.general` `snap` module's `process_one`
IndexError), one option is to **tag the task** and **add the tag to the workflow
`--skip-tags`** list. Precedent: the snap tasks in
`roles/desktop-apps/tasks/debian.yml` are tagged `snaps`, and `snaps` is in the
skip list.

Do **not** do this automatically — skipping a task hides real coverage, so
**ask the user** whether they want to skip it (versus pinning a working module
version, or fixing it another way) before editing the workflow. If they agree,
`log`/note what was skipped so it isn't mistaken for covered.

## Merging

Merge only when the user has asked you to — never merge a PR automatically just
because checks went green. Check mergeability with valid JSON fields, then
merge:

```bash
gh pr view <n> --json mergeable,mergeStateStatus
gh pr merge <n> --merge
```

Use `--merge` (a merge commit) — `main`'s history is a series of "Merge pull
request #…" commits. Do not squash-merge (it collapses the curated commits; see
`[[tidy-branch-history]]`).

## Common mistakes to avoid

- **Silently unsetting `GH_TOKEN`** to dodge a `401` — surface the auth failure
  to the user first; only bypass it if they ask.
- **Merging without being asked** — going green is not permission to merge.
- **Invalid `--json` fields** — e.g. there is no `merged` field; use `state`
  (`MERGED`) or `mergedAt`. `gh` lists valid fields in the error.
- **Merging right after a force-push** — the old (green) checks may still be
  showing; wait for the re-triggered run to finish before merging.
- **Reading the whole run log** — use `--log-failed` to jump straight to the
  failing step.

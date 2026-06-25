---
description: >
  How to push changes and drive a pull request's CI to green for this
  repository using the gh CLI. Load this whenever monitoring PR checks,
  diagnosing a failed build, or merging. Covers the critical
  `env -u GH_TOKEN` quirk, the watch/inspect loop, reading the Ansible
  play recap, and the merge convention.
---

# Monitoring CI and merging PRs

## Always strip GH_TOKEN from gh calls

The ambient `GH_TOKEN` environment variable in this environment is **invalid**
(`gh` will return `HTTP 401 Bad credentials`). Stripping it lets `gh` fall back
to the valid token in the keyring. So prefix **every** `gh` command with
`env -u GH_TOKEN`:

```bash
env -u GH_TOKEN gh pr checks 77
```

This is the single biggest time-saver in this skill — without it, every `gh`
call fails with a confusing auth error.

## The loop: push → watch → inspect → fix

1. **Push** your branch (`git push`, or `git push --force-with-lease` after a
   rebase — see `[[tidy-branch-history]]`).
2. **Watch** the checks to completion (run in the background):
   ```bash
   env -u GH_TOKEN gh pr checks <n> --watch --interval 30
   ```
3. On failure, **inspect** the failing run's log:
   ```bash
   env -u GH_TOKEN gh pr checks <n>          # find the failed run's URL/id
   env -u GH_TOKEN gh run view <run-id> --log-failed
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
IndexError),
don't fight it: **tag the task** and **add the tag to the workflow
`--skip-tags`** list. Precedent: the snap tasks in
`roles/desktop-apps/tasks/debian.yml` are tagged `snaps`, and `snaps` is in the
skip list. Always `log`/note what was skipped so it isn't mistaken for covered.

## Merging

Check mergeability with valid JSON fields, then merge:

```bash
env -u GH_TOKEN gh pr view <n> --json mergeable,mergeStateStatus
env -u GH_TOKEN gh pr merge <n> --merge
```

Use `--merge` (a merge commit) — `main`'s history is a series of "Merge pull
request #…" commits. Do not squash-merge (it collapses the curated commits; see
`[[tidy-branch-history]]`).

## Common mistakes to avoid

- **Omitting `env -u GH_TOKEN`** — every `gh` call 401s.
- **Invalid `--json` fields** — e.g. there is no `merged` field; use `state`
  (`MERGED`) or `mergedAt`. `gh` lists valid fields in the error.
- **Merging right after a force-push** — the old (green) checks may still be
  showing; wait for the re-triggered run to finish before merging.
- **Reading the whole run log** — use `--log-failed` to jump straight to the
  failing step.

---
description: >
  Create pull requests for this repository. Covers branch workflow,
  the gh CLI, filling the PR template, and common mistakes to avoid.
---

# Creating pull requests

## Step 1: Read the PR template

Before creating a PR, read `.github/pull_request_template.md` with
the Read tool. Do not assume you know the template contents — always
read it at runtime, as it may have changed.


## Step 2: Create and push the branch

1. **Create a feature branch** from the base branch (usually `main`).
   - If already on a feature branch, do not create a new branch unless
     told to by the user.
2. **Push the branch** to GitHub: `git push`.


## Step 3: Create the PR

Create the PR with `gh pr create --draft`.

- If `gh` is not installed, **stop** and ask the user whether they want
  you to install it or whether they prefer to install it themselves.
  Installation commands by platform:
  - Linux: follow the instructions at
    <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>
  - macOS: `brew install gh`
- Always use `--draft`. All PRs in this repository must be created as
  drafts.

## Step 4: Fill the PR template

When filling the template:

- Write a clear description explaining why the PR is needed.
- Add a "Closes: #issue" line if the changes relate to an issue
  being worked on.
- In the "Test plan" section, leave the boxes unchecked. The
  human operator will normally check this box when tests pass.
- In the "Author tasks" section, retain any items that must be completed for
  the current PR and remove any that are not relevant.
- **Never add extra checkboxes** unless the user tells you to.
- **Do not wrap paragraphs.** Write each paragraph as a single long line and let
  GitHub flow it. Hard line breaks inside a paragraph add no value (GitHub renders
  them as soft breaks rather than helpful wrapping) and force reviewers to scroll
  awkwardly when the column count differs from yours. Keep one blank line between
  paragraphs as the only separator. List items follow the same rule — one item
  per line, no mid-item wrapping.


## Common mistakes to avoid

### Forgetting `--draft`

All PRs in this repository must be created as drafts. Never use
`gh pr create` without `--draft`.

### Adding extra checkboxes

The template has a fixed set of checkboxes. Do not invent new ones.
Only check existing boxes that are relevant.

### Not reading the template at runtime

The PR template may change over time. Always read
`.github/pull_request_template.md` before creating a PR. Do not rely
on cached or memorized template content.

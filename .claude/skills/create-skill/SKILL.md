---
description: >
  How to write a new Claude Code skill (or edit an existing one) in this
  repository. Load this whenever creating a SKILL.md under .claude/skills/.
  Covers the directory layout, frontmatter, body structure, voice, and —
  critically — the markdownlint and textlint rules the super-linter
  enforces on every new or edited Markdown file, so the skill passes CI
  on the first push.
---

# Writing a Claude Code skill

A skill is a single Markdown file that teaches future sessions how to do
something specific in this repository. Existing examples worth reading first:
`.claude/skills/git-commit/SKILL.md`, `.claude/skills/create-pr/SKILL.md`, and
the apt/CI skills (`[[apt-repos]]`, `[[monitor-ci]]`).

## Layout and naming

- One skill per directory: `.claude/skills/<name>/SKILL.md`.
- The **directory name is the skill name** — kebab-case, e.g.
  `github-release-version`. There is no `name:` field in the frontmatter.
- Name skills for the task they serve (a verb or a topic), not the tool they
  happen to use.

## Frontmatter

Start the file with a YAML block containing a single folded `description`:

```yaml
---
description: >
  One or two sentences saying WHAT the skill covers and, just as important,
  WHEN to load it (the trigger). This text is all a future session sees when
  deciding whether the skill is relevant, so lead with the trigger.
---
```

Write the description so the trigger is obvious: "Load this when …",
"… whenever you …". A vague description means the skill never gets loaded at
the right moment.

## Body structure

- Exactly **one** top-level heading (`#`) — the skill title. Everything else is
  `##` / `###`. (Multiple `#` headings fail markdownlint MD025.)
- Lead with the most important rule; don't bury it under preamble.
- End with a `## Common mistakes to avoid` section — a bulleted list of the
  traps, each with the consequence.
- Keep it concise and concrete. Show the exact command or task, and say *why*.
  Copy code snippets verbatim from real files and cite the path, so examples
  stay accurate.

## Voice

Imperative and second-person, matching the existing skills: "Use X", "Always
…", "Do not …". Prefer a short rule plus its rationale over a long essay.

## Cross-linking

Relate skills with `[[skill-name]]` (the other skill's directory name), e.g.
`[[git-commit]]`. Link liberally — it points a future session at the next
relevant skill.

## Pass the super-linter

Every new or edited Markdown file is linted by the `run-lint` job (see
`[[monitor-ci]]`). There is no local linter, so follow these rules as you write
to avoid a wasted CI round. The two linters that bite skills are markdownlint
and textlint.

**markdownlint:**

- Begin every fenced code block with a language tag — for example `yaml`,
  `bash`, or `text`. A bare triple-backtick fence fails MD040. Closing fences
  stay bare.
- No bare URLs in prose. Wrap a link in angle brackets (`<https://example.com>`)
  or use `[text](https://example.com)`.
- One `#` heading only (see above).
- No spaces just inside a code span: write `` `fixup!` `` plus the word "prefix"
  in prose, not a code span with a trailing space.

**textlint (the `terminology` rule)** checks **prose only** — it skips code
spans and code blocks, so variable names like `docker_repo` are fine. In prose,
use the canonical spelling (the discouraged forms below are shown as code spans
so this very file passes the rule):

- Use "repository" — never `repo`.
- Use "GitHub" — never `Github` or `github`. A bare `github.com` host inside a
  code span or URL is fine.
- Use "OK" — never `ok`.

When in doubt, phrase the wording the way the existing skills do.

## Common mistakes to avoid

- **A vague `description`** — the skill won't be loaded when it's needed. State
  the trigger explicitly.
- **Adding a `name:` field** — the directory name is the name.
- **Multiple `#` headings** — fails MD025; use one `#`, then `##`/`###`.
- **Bare code fences or bare URLs** — fail markdownlint; tag every fence and
  wrap every URL.
- **Writing `repo` or `Github` in prose** — fails textlint; use "repository" or
  "GitHub". Code spans and code blocks are exempt.
- **Inventing snippets** — copy from real files and cite the path so the
  example doesn't drift.

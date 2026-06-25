---
description: >
  Conventions for writing or modifying any Ansible role or task in this
  repository. Load this before editing anything under roles/ or playbooks/.
  Covers the distro-dispatch role layout, the os_distro/os_codename
  facts, defaults, idempotency rules for read-only tasks, become usage,
  and the tagging convention. Points to specialised skills for apt
  repositories and GitHub release lookups.
---

# Ansible conventions for this repository

## Role layout: distro dispatch

`tasks/main.yml` is a thin dispatcher; the real work lives in a per-OS-family
file. Every role follows this:

```yaml
# roles/<role>/tasks/main.yml
- name: <describe the role>
  include_tasks: "{{ ansible_os_family | lower }}.yml"
```

So Debian/Ubuntu work goes in `tasks/debian.yml`. Put distro-specific logic in
the included file, **never** in `main.yml`.

## Facts: os_distro and os_codename

`pre_tasks` in `playbooks/linux-desktop.yml` (tagged `always`, so they run even
under `--tags <role>`) set two facts you should use instead of hard-coding:

- **`os_distro`** — from `ansible_distribution`, normalized (`Linux Mint` →
  `ubuntu`). Use `{{ os_distro|lower }}` where a URL/path varies by distro.
- **`os_codename`** — looked up from the `os_codenames` map in
  `inventories/group_vars/all.yml`, falling back to
  `ansible_distribution_release`. Use `{{ os_codename }}` for a repository's
  `suites:`.

Hard-coding a codename like `jammy` is a bug — it breaks on other releases.

### Prefer dict-indexed facts in new code

Newer Ansible deprecates the injected top-level fact variables
(`ansible_os_family`, `ansible_distribution`, `ansible_distribution_release`)
and warns when you use them; the supported form is dict-indexed under
`ansible_facts` — `ansible_facts['os_family']`, `ansible_facts['distribution']`,
and so on. The dispatch include and `pre_tasks` above still use the injected
form to match the existing code, which is what produces those deprecation
warnings. Use `ansible_facts['...']` for new code, and converting the existing
usages is the way to silence the warnings.

## Defaults and variables

Role defaults go in `defaults/main.yml` with a `# defaults file for <role>`
comment, e.g. `roles/apt/defaults/main.yml`:

```yaml
---
# defaults file for apt
os_update: false
```

Shared/global vars and the `os_codenames` map live in
`inventories/group_vars/all.yml`.

## Idempotency: read-only tasks

Tasks that only *inspect* state must not report changes or fail the run, and
must still run under `--check`:

```yaml
- name: Check if current <pkg> version is already installed
  shell: "dpkg-query -W -f='${Version}' <pkg>"
  register: <pkg>_installed_version
  failed_when: no
  changed_when: no
  check_mode: no
```

- `check_mode: no` — the task runs even in `--check` mode (so a `--check` run
  doesn't leave dependent facts undefined).
- `changed_when: no` / `failed_when: no` — a pure query is never a "change" and
  a non-zero exit (package absent) is not a failure.

The same applies to `uri` HEAD lookups — see `[[github-release-version]]`.

## become

Roles generally run in a root context already, so most tasks omit `become:`.
Add `become: yes` only on the **specific task** that needs elevation (e.g. the
`get_url` writing to `/usr/local/bin` in `roles/rbw/tasks/debian.yml`), not
blanketed across the role.

## Tagging

Every role is wired into `playbooks/linux-desktop.yml` with a **role-specific
tag plus category tags** drawn from a shared vocabulary (`apps`, `desktop`,
`system`, `development`, `security`, `virtual`, `devices`, `collaboration`,
`communication`):

```yaml
- role: chrome
  tags:
    - apps
    - desktop
    - chrome
```

If an individual task may need to be skipped in CI (e.g. an unfixable upstream
module bug), give that task its own tag and add it to the workflow's
`--skip-tags` — see `[[monitor-ci]]`.

## Collections and roles are pinned

External dependencies are pinned in `collections/requirements.yml`. Pinned
versions matter — e.g. the `community.general` version carries the `snap`
module bug. Don't bump a pin casually.

## Specialised skills

- Adding/changing an **apt repository** → load `[[apt-repos]]` (the deb822
  cache-refresh rule and vendor self-management).
- Looking up the **latest GitHub release** of a tool → load
  `[[github-release-version]]`.

## Common mistakes to avoid

- **Putting distro-specific work in `tasks/main.yml`** — it belongs in
  `debian.yml`; `main.yml` only dispatches.
- **Hard-coding a codename** instead of `{{ os_codename }}`.
- **Omitting `check_mode: no`** on a lookup task — downstream facts become
  undefined under `--check`.
- **Blanket `become:`** instead of scoping it to the task that needs it.

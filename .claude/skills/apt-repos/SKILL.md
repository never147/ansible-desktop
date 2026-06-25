---
description: >
  Rules for adding, changing, or debugging an apt repository in any role
  in this repository. Load this BEFORE touching anything under
  /etc/apt/sources.list.d or any `deb822_repository` / `apt_repository`
  task. Covers the deb822 cache-refresh pattern (a non-obvious regression
  source) and how to stop vendor packages (Chrome, Slack, Spotify) from
  fighting Ansible over their repository files.
---

# Managing apt repositories

This repository uses **deb822 `.sources`** files (the `deb822_repository`
module), not the legacy `.list` format (`apt_repository` / `apt_key`).

## Always refresh the cache after adding a repository

**`deb822_repository` does NOT update the apt cache.** This is the single most
important fact in this skill. The legacy `apt_repository` module defaults to
`update_cache: yes`, so the migration to deb822 silently dropped the refresh —
which caused a CI failure where a freshly added package could not be found
(`No package matching … available`).

So: **`register:` the repository task and add one conditional cache update per
role**, gated on the registered result being changed. One refresh per role,
only when something actually changed — never an unconditional `apt-get update`
on every play (that is slow and was explicitly rejected).

```yaml
- name: Add docker repository
  deb822_repository:
    name: docker
    types: deb
    uris: "https://download.docker.com/linux/{{ os_distro|lower }}"
    suites: "{{ os_codename }}"
    components: stable
    architectures: amd64
    signed_by: "https://download.docker.com/linux/{{ os_distro|lower }}/gpg"
  register: docker_repo

- name: Update apt cache when the Docker repository changed
  apt:
    update_cache: yes
  when: docker_repo is changed
```

(See `roles/docker/tasks/debian.yml`, `roles/vagrant/tasks/debian.yml`,
`roles/yubikey/tasks/debian.yml` for the same shape.)

### Several repositories in one role → one coalesced cache update

When a role adds more than one repository, do **not** add a cache update after
each. Register each one, then do a single `update_cache` gated on the OR of all
of them. Guard with `is defined` for repositories added by
conditionally-included task files. From `roles/desktop-apps/tasks/debian.yml`:

```yaml
- name: Update apt cache when a desktop repository changed
  apt:
    update_cache: yes
  when: >
    mozillateam_repo is changed
    or (spotify_repo is defined and spotify_repo is changed)
    or (sublime_repo is defined and sublime_repo is changed)
    or (dropbox_repo is defined and dropbox_repo is changed)
```

## Standard sequence for a repository

1. Remove the legacy `.list` (and old keys from the legacy keyring, with
   `failed_when: false` so a missing key is not an error).
2. `deb822_repository` with `signed_by:` pointing at the key URL, `register:`d.
3. Conditional `update_cache`.
4. The `apt:` install task(s).

Use `{{ os_codename }}` for `suites:` and `{{ os_distro|lower }}` where the URL
varies by distro — see `[[ansible-conventions]]` for where those facts come
from.

## Self-managing vendor repositories

Some packages re-create their own repository file via a postinst maintainer
script and/or `/etc/cron.daily/<pkg>`. Left alone, the vendor file
**duplicates** the Ansible-managed one (`apt-get update` then warns "Target … is
configured multiple times") or silently overwrites it. Before adding such a
repository, check whether the package self-manages, and neutralize it.

Each vendor uses a different opt-out mechanism — there is no single trick:

- **Spotify** — its postinst writes `spotify.list` only **if absent**. Ship an
  empty stub `spotify.list` so it never adds a real line. The real definition is
  the Ansible-managed `spotify.sources`. See
  `roles/desktop-apps/tasks/spotify-repo.yml`.

- **Chrome** — the postinst **and** `/etc/cron.daily/google-chrome` rewrite an
  existing `google-chrome.sources`. So you must do three things
  (`roles/chrome/tasks/debian.yml`):
  1. Remove **both** `google-chrome.list` and `google-chrome.sources`.
  2. Write `/etc/default/google-chrome` with `repo_add_once="false"` and
     `repo_reenable_on_distupgrade="false"`.
  3. Own the definition under a **distinct filename** the vendor never touches —
     `name: google-chrome-managed` → `google-chrome-managed.sources`. (Using
     `google-chrome` would let the vendor rewrite your file.)

- **Slack** — write `/etc/default/slack` with the same two flags and remove
  `slack.list`. The vendor never recreates `slack.sources` once the flags are
  off. See `roles/slack/tasks/debian.yml`.

**Ordering:** the removals + `/etc/default/<pkg>` flags + the deb822 task must
all run **before** the `apt` install, so a fresh install's postinst sees the
flags off and no file to recreate.

## dpkg-divert does not apply

Do not reach for `dpkg-divert`. It only redirects files that dpkg itself
installs from inside a `.deb`. None of these files are dpkg-owned — they are
written by maintainer scripts/cron — so there is nothing to divert.

## Verifying

- `apt-get update` emits no "configured multiple times" warning.
- Re-running the role is idempotent even after forcing the vendor scripts:
  `sudo /etc/cron.daily/<pkg>` then re-run → the role reports no change.
- Exactly one active definition per repository in `/etc/apt/sources.list.d/`.

## Common mistakes to avoid

- **Forgetting the cache update** after a `deb822_repository` — the package
  won't be found on a fresh machine. This is the deb822 trap.
- **Unconditional `apt-get update`** on every run instead of `when: … is
  changed` — slow, and was explicitly rejected.
- **Using the vendor's own filename** for a self-managing repository (Chrome) —
  it will be overwritten. Use a distinct `*-managed.sources` name.
- **Reaching for `dpkg-divert`** — inapplicable here.

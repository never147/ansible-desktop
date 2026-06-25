---
description: >
  How to look up the latest GitHub release version of a tool from an
  Ansible task in this repository. Load this whenever a role needs "the newest
  version of <tool> on GitHub" to build a download URL. Covers the
  web-endpoint HEAD-redirect pattern and why the api.github.com endpoint
  must NOT be used (it is rate-limited and 403s in CI).
---

# Looking up the latest GitHub release version

To find a tool's latest release version, do a `HEAD` request to the **web**
`releases/latest` URL and parse the version out of the redirect target. Do
**not** call `api.github.com`.

## Why not the API

`https://api.github.com/repos/<owner>/<repo>/releases/latest` is limited to
**60 requests/hour for unauthenticated clients**. CI runs unauthenticated, so a
single API call can `403` and fail the build — this exact thing broke the `rbw`
role. The web endpoint at `github.com` redirects `releases/latest` →
`releases/tag/<tag>` and is not rate-limited the same way. Existing roles
(`gopass`, `pandoc`) already rely on it.

## The pattern

```yaml
- name: Get rbw version information from GitHub
  uri:
    url: "https://github.com/doy/rbw/releases/latest"
    method: HEAD
    headers:
      User-Agent: "Mozilla/5.0 (X11; Linux x86_64)"
  register: rbw_url_response
  check_mode: no

- block:
    - name: Set rbw version
      set_fact:
        rbw_available_version: "{{ rbw_url_response.url.split('/')[-1].strip('v') }}"
  rescue:
    - name: No rbw version info
      debug:
        msg: "No version info found for rbw"
    - name: Set empty rbw version
      set_fact:
        rbw_available_version: ""
```

Key points:

- **`method: HEAD`** — we only need the redirect, not the body. (`uri` follows
  redirects by default, so `.url` is the final tagged URL.)
- **`User-Agent` header** — GitHub rejects requests without one.
- **`check_mode: no`** — the lookup must run even under `--check`, otherwise the
  version fact is undefined and downstream tasks break. See
  `[[ansible-conventions]]`.
- **Parse expression** `{{ resp.url.split('/')[-1].strip('v') }}` — takes the
  last path segment (`v1.15.0`) and strips a leading `v` → `1.15.0`.
- **`block`/`rescue`** — if GitHub is unreachable or the parse fails, set the
  version to empty/null instead of failing the whole play.

## Gate the install on a version comparison

Pair the lookup with a `dpkg-query` check and only install when newer (these
read-only tasks are non-destructive, so mark them accordingly):

```yaml
- name: Check if current rbw version is already installed
  shell: "dpkg-query -W -f='${Version}' rbw"
  register: rbw_installed_version
  failed_when: no
  changed_when: no
  check_mode: no

- name: Install rbw if newer version available
  apt:
    deb: "https://git.tozt.net/rbw/releases/deb/rbw_{{ rbw_available_version }}_amd64.deb"
  when:
    - rbw_available_version is defined
    - rbw_available_version != ""
    - rbw_installed_version.stdout == '' or rbw_available_version is version(rbw_installed_version.stdout, '>')
```

Reference implementations: `roles/rbw/tasks/debian.yml`,
`roles/gopass/tasks/debian.yml`.

## Common mistakes to avoid

- **Using `api.github.com`** — rate-limited, 403s in CI. Use the `github.com`
  web endpoint.
- **Omitting `check_mode: no`** — breaks `--check` runs (the version fact never
  gets set).
- **No `block`/`rescue`** — a transient network/parse failure takes down the
  whole play instead of degrading gracefully.
- **Forgetting the `User-Agent`** — GitHub rejects the request.

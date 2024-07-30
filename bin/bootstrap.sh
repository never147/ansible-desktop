#!/usr/bin/env bash
set -ex

sudo apt-get install -y \
  --install-recommends \
  python3-full python3-dev \
  pipx libffi-dev

mkdir -p ~/.local/bin
export PATH="${PIPX_HOME}"/bin:~/.local/bin:"${PATH}"

pipx install poetry


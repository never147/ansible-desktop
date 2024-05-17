#!/usr/bin/env bash
set -x

sudo apt-get install -y \
  --install-recommends \
  python3-full python3-dev \
  pipx libffi-dev

mkdir -p ~/.local/bin
export PATH=$PATH:~/.local/bin

pipx install poetry

poetry install

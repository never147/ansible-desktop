#!/usr/bin/env bash
set -ex

sudo apt-get install -y \
  --install-recommends \
  python3-full python3-dev \
  pipx libffi-dev

pipx install poetry


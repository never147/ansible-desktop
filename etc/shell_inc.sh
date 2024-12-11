#!/usr/bin/env bash

export PIPX_HOME="${PIPX_HOME:-"$HOME"/.ansible-desktop/}"
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export PIPX_MAN_DIR="${PIPX_HOME}/share/man"
export PATH="$PIPX_BIN_DIR:$PATH"

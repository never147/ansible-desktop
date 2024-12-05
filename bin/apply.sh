#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1
export PIPX_HOME="${PIPX_HOME:-"$HOME"/.ansible-desktop/}"
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export PIPX_MAN_DIR="${PIPX_HOME}/share/man"
export PATH="$PIPX_BIN_DIR:$PATH"

if [ ! -e "${PIPX_BIN_DIR}"/poetry ] ;then
    ./bin/bootstrap.sh || exit 1
fi

if [ -z "${UNATTENDED:-}" ] ;then
  poetry install
fi

VENV_DIR=$(poetry env info -p)
# export ANSIBLE_COW_SELECTION=none
export ANSIBLE_CALLBACK_WHITELIST=unixy
export ANSIBLE_STDOUT_CALLBACK=unixy
export ANSIBLE_COLLECTIONS_PATH="$VENV_DIR"/collections
export ANSIBLE_ROLES_PATH="$VENV_DIR"/roles:"$base"/roles

if [ -z "${UNATTENDED:-}" ] ;then
  (
    cd "$base"/collections \
    && poetry run ansible-galaxy collection install \
        -p "${VENV_DIR}/collections" -r requirements.yml \
    && poetry run ansible-galaxy role install \
        -p "${VENV_DIR}/roles" -r requirements.yml
  )
fi

poetry run ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  "${ANSIBLE_PLAYBOOK:=playbooks/linux-desktop.yml}" \
  "$@"

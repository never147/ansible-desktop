#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1
. etc/shell_inc.sh

if [ ! -e "${PIPX_BIN_DIR}"/poetry ] ;then
    ./bin/bootstrap.sh || exit 1
fi

if [ -z "${UNATTENDED:-}" ] ;then
  poetry install
fi

. etc/ansible_inc.sh

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
  -i "${ANSIBLE_INVENTORY:=inventories/local}" \
  "${ANSIBLE_PLAYBOOK:=playbooks/linux-desktop.yml}" \
  "$@"

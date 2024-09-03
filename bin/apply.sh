#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1
export PIPX_HOME="${PIPX_HOME:-"$HOME"/.ansible-desktop/}"
export PATH="$PIPX_HOME/venvs/poetry/bin:$PATH"

if [ ! -e "${PIPX_HOME}"/venvs/poetry/bin/poetry ] ;then
    ./bin/bootstrap.sh || exit 1
fi

poetry install

VENV_DIR=$(poetry env info -p)
(
  cd "$base"/collections \
  && poetry run ansible-galaxy collection install \
      -p "${VENV_DIR}/collections" -r requirements.yml \
  && poetry run ansible-galaxy role install \
      -p "${VENV_DIR}/roles" -r requirements.yml
)


# ANSIBLE_COW_SELECTION=none \
ANSIBLE_CALLBACK_WHITELIST=unixy \
ANSIBLE_STDOUT_CALLBACK=unixy \
ANSIBLE_COLLECTIONS_PATH="$VENV_DIR"/collections \
ANSIBLE_ROLES_PATH="$VENV_DIR"/roles:"$base"/roles \
poetry run ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  "${ANSIBLE_PLAYBOOK:=playbooks/linux-desktop.yml}" \
  "$@"

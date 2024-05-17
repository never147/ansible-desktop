#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1

if [ ! -f ~/.local/bin/poetry ] ;then
    ./bin/bootstrap.sh
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

[ -z "$CI" ] && ANSIBLE_EXTRA_ARGS=("--ask-become-pass")

# ANSIBLE_COW_SELECTION=none \
ANSIBLE_CALLBACK_WHITELIST=unixy \
ANSIBLE_STDOUT_CALLBACK=unixy \
ANSIBLE_COLLECTIONS_PATH="$VENV_DIR"/collections \
ANSIBLE_ROLES_PATH="$VENV_DIR"/roles:"$base"/roles \
poetry run ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  "${ANSIBLE_EXTRA_ARGS[@]}" \
  "${ANSIBLE_PLAYBOOK:=playbooks/linux-desktop.yml}" \
  "$@"

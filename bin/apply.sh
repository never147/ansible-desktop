#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1
VENV_DIR=${VENV_DIR:="$HOME"/Apps/virtualenvs/home_dir}

if [ ! -f "$VENV_DIR"/bin/activate ] ;then
    ./bin/bootstrap.sh
fi
. "$VENV_DIR"/bin/activate

(
  cd "$base"/collections \
  && ansible-galaxy collection install -p "${VENV_DIR}/collections" -r requirements.yml \
  && ansible-galaxy role install -p "${VENV_DIR}/roles" -r requirements.yml
)

[ -z "$CI" ] && ANSIBLE_EXTRA_ARGS=("--ask-become-pass")

# ANSIBLE_COW_SELECTION=none \
ANSIBLE_CALLBACK_WHITELIST=unixy \
ANSIBLE_STDOUT_CALLBACK=unixy \
ANSIBLE_COLLECTIONS_PATH="$VENV_DIR"/collections \
ANSIBLE_ROLES_PATH="$VENV_DIR"/roles:"$base"/roles \
ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  "${ANSIBLE_EXTRA_ARGS[@]}" \
  "${ANSIBLE_PLAYBOOK:=playbooks/linux-desktop.yml}" \
  "$@"

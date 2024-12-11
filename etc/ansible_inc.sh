#!/usr/bin/env bash

BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/.. && pwd -P)"

VENV_DIR=$(poetry env info -p)
# export ANSIBLE_COW_SELECTION=none
export ANSIBLE_CALLBACK_WHITELIST=unixy
export ANSIBLE_STDOUT_CALLBACK=unixy
export ANSIBLE_COLLECTIONS_PATH="$VENV_DIR"/collections
export ANSIBLE_ROLES_PATH="$VENV_DIR"/roles:"$BASE"/roles


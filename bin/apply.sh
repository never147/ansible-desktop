#!/usr/bin/env bash

base=$(dirname "$0")/..
cd "$base" || exit 1
if [ ! -f "$HOME"/Apps/virtualenvs/home_dir/bin/activate ] ;then
    ./bin/bootstrap.sh
fi
. "$HOME"/Apps/virtualenvs/home_dir/bin/activate

# ANSIBLE_COW_SELECTION=none \
ANSIBLE_CALLBACK_WHITELIST=unixy \
ANSIBLE_STDOUT_CALLBACK=unixy \
ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  --ask-become-pass \
  playbooks/linux-desktop.yml \
  "$@"

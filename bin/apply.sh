#!/usr/bin/env bash

base=$(dirname $0)/..
cd $base
if [ ! -f $HOME/Apps/virtualenvs/home_dir/bin/activate ] ;then
    ./bin/bootstrap.sh
fi
. $HOME/Apps/virtualenvs/home_dir/bin/activate

ANSIBLE_COW_SELECTION=random ansible-playbook \
  -e @personal.yml \
  -i inventories/local \
  --ask-become-pass \
  playbooks/linux-desktop.yml \
  $@

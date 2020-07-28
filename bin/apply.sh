#!/usr/bin/env bash

base=$(dirname $0)/..
cd $base
if [ ! -f $HOME/Apps/virtualenvs/home_dir/bin/activate ] ;then
    ./bootstrap.sh
else
    . $HOME/Apps/virtualenvs/home_dir/bin/activate
fi

ANSIBLE_COW_SELECTION=random ansible-playbook \
  -e @personal.yml \
  -i enviro/local \
  --ask-become-pass \
  playbooks/linux-desktop.yml \
  $@

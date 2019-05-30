#!/usr/bin/env bash

base=$(dirname $0)
cd $base
ANSIBLE_COW_SELECTION=random ansible-playbook \
  -e @personal.yml \
  -i enviro/local \
  --ask-become-pass \
  playbooks/linux-desktop.yml \
  $@

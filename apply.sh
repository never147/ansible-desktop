ANSIBLE_COW_SELECTION=random ansible-playbook \
  -e @personal.yml \
  -i enviro/local \
  --ask-become-pass \
  playbooks/linux-desktop.yml \
  $@

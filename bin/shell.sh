#!/usr/bin/env bash

BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/.. && pwd -P)"

cd "$BASE" || exit 1
. etc/shell_inc.sh
. etc/ansible_inc.sh

poetry shell

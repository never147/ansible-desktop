#!/usr/bin/env bash
set -x
BASE=$(dirname $0)/..

sudo apt-get install -y --install-recommends python3-dev

mkdir -p ~/.local/bin
export PATH=$PATH:~/.local/bin

if [ -f ~/.pip/pip.conf ] ;then
    mv ~/.pip/pip.conf ~/.pip/pip.conv.orig
fi

export WORKON_HOME=$HOME/Apps/virtualenvs
mkdir -p $WORKON_HOME
python3 -m venv $WORKON_HOME/home_dir
. $WORKON_HOME/home_dir/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

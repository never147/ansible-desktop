#!/usr/bin/env bash
set -x

sudo apt-get install -y --install-recommends python-dev python-pip

mkdir -p ~/.local/bin
export PATH=$PATH:~/.local/bin

if [ -f ~/.pip/pip.conf ] ;then
    mv ~/.pip/pip.conf ~/.pip/pip.conv.orig
fi
pip install -i https://pypi.org/simple --user virtualenv virtualenvwrapper
source $(which virtualenvwrapper.sh)

export WORKON_HOME=$HOME/Apps/virtualenvs
mkdir -p $WORKON_HOME
mkvirtualenv home_dir
pip install -r requirements.txt

#!/bin/bash

version=0.1

if ! [ -d bcwc_pcie ] ;then
    echo "Download https://github.com/patjak/bcwc_pcie/tree/mainline to pwd"
    exit 1
fi
set -e

cd bcwc_pcie
mkdir -p /usr/src/facetimehd-$version
cp -r -- * /usr/src/facetimehd-$version/
cd /usr/src/facetimehd-$version/
rm -f backup-*tgz bcwc-pcie_*deb
make clean
dkms add -m facetimehd -v $version
dkms build -m facetimehd -v $version
dkms mkdsc -m facetimehd -v $version --source-only
dkms mkdeb -m facetimehd -v $version --source-only
cp /var/lib/dkms/facetimehd/$version/deb/facetimehd-dkms_${version}_amd64.deb .
rm -fr /var/lib/dkms/facetimehd/
dpkg -i facetimehd-dkms_${version}_amd64.deb

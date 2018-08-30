#!/bin/bash

CORD_VER='cord-5.0'
BRANCH='master' #$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
DST=~/cord

# Copy new files into our target
cp docker_images.yml $DST/build
cp mcord-oai.yml $DST/orchestration/profiles/mcord/

# Copy podconfig
cp mcord-oai-virtual.yml $DST/orchestration/profiles/mcord/podconfig/
cp mcord-oai-physical.yml $DST/orchestration/profiles/mcord/podconfig/

# Copy Template files
cp mcord-oai-services.yml.j2 $DST/orchestration/profiles/mcord/templates/
cp mcord-oai-address-manager.yml.j2 $DST/orchestration/profiles/mcord/templates/
cp vtn-service.yaml.j2 $DST/orchestration/profiles/mcord/templates/
#cp public-net.yaml.j2 $DST/orchestration/profiles/mcord/templates/
cp mcord-oai-test-playbook.yml $DST/orchestration/profiles/mcord/test/
cp manifest.xml $DST/.repo/manifests/default.xml
cp config-maas.yml ~/cord/build/maas/roles/maas/tasks/config-maas.yml

# Use custom version of services instead official
cd ~/cord/orchestration/xos_services

for var in "vbbu" "vhss" "vmme" "vspgwc" "vspgwu" "epc-service"; do
    rm -rf $var;
    git clone https://github.com/aweimeow/$var.git $var;
    cd $var;
    git remote add opencord https://github.com/aweimeow/$var.git;
    git remote add dev git@github.com:aweimeow/$var.git;
    git checkout $BRANCH;
    git checkout -b $CORD_VER;
    mkdir .git/refs/remotes/opencord/;
    echo $(git log --format="%H" -n 1) > .git/refs/remotes/opencord/$CORD_VER;
    cd ..;
done

rm -rf oaibbu;
git clone https://github.com/nick133371/oaiBBU oaibbu;
cd oaibbu;
git remote add opencord https://github.com/nick133371/oaiBBU.git;
git remote add dev git@github.com:nick133371/oaiBBU.git;
git checkout $BRANCH;
git checkout -b $CORD_VER;
mkdir .git/refs/remotes/opencord/;
echo $(git log --format="%H" -n 1) > .git/refs/remotes/opencord/$CORD_VER;
cd ..;

rm -rf epc-service;
git clone https://github.com/nick133371/epc-service epc-service;
cd epc-service;
git remote add opencord https://github.com/nick133371/epc-service.git;
git remote add dev git@github.com:nick133371/epc-service.git;
git checkout $BRANCH;
git checkout -b $CORD_VER;
mkdir .git/refs/remotes/opencord/;
echo $(git log --format="%H" -n 1) > .git/refs/remotes/opencord/$CORD_VER;
cd ..;

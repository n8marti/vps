#!/bin/bash

# Ensure installation and proper configuration of a dulu container on lxd.
# This script assumes an Ubuntu Server 20.04 host.

PARENT_DIR=$(dirname $(realpath $0))

# Ensure installation of snapd.
if [[ ! $(which snap) ]]; then
    sudo apt-get --yes update
    sudo apt-get --yes upgrade
    sudo apt-get --yes install snap
fi

# Ensure installation of lxd.
if [[ ! $(which lxd) ]]; then
    sudo snap install lxd
fi

# Ensure initialization of lxd.
preseed_file="${PARENT_DIR}/lxd-dulu-preseed.yaml"
cat "$preseed_file" | lxd init --preseed

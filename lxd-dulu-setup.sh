#!/bin/bash

# Ensure installation and proper configuration of a dulu container on lxd.
# This script assumes an Ubuntu Server 20.04 host.

PARENT_DIR=$(dirname $(realpath $0))

# Ensure installation of snapd.
if [[ ! $(which snap) ]]; then
    echo "Updating and installing snap package..."
    sudo apt-get --yes update
    sudo apt-get --yes upgrade
    sudo apt-get --yes install snap
fi

# Ensure installation of lxd.
if [[ ! $(which lxd) ]]; then
    echo "Installing lxd..."
    sudo snap install lxd
fi

# Ensure initialization of lxd.
if [[ ! $(lxc storage list | grep dulu) ]]; then
    echo "Initializing lxd..."
    preseed_file="${PARENT_DIR}/lxd-dulu-preseed.yaml"
    cat "$preseed_file" | sudo lxd init --preseed
fi

# Ensure creation of dulu server container.
if [[ ! $(lxc list dulu) ]]; then
    echo "Creating dulu-18.04 instance..."
    lxc launch ubuntu:18.04 dulu-18.04
fi

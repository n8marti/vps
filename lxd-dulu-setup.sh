#!/bin/bash

# Ensure installation and proper configuration of a dulu container on lxd.
# This script assumes an Ubuntu Server 20.04 host.

PARENT_DIR=$(dirname $(realpath $0))
NAME='dulu-1804'

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
if [[ ! $(lxc list | grep "$NAME") ]]; then
    lxc launch ubuntu:18.04 "$NAME" --verbose --profile=default --profile=dulu
fi

# Login to ubuntu user.
echo "$NAME has been setup. Logging in..."
lxc exec "$NAME" -- sudo --login --user ubuntu

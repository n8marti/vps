#!/bin/bash

# Ensure installation and proper configuration of a dulu container on lxd.
# This script assumes an Ubuntu Server 20.04 host.

PARENT_DIR=$(dirname $(realpath $0))
NAME='dulu-1804'
$DULU_USER='dulu'

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

# Create dulu user on dulu-1804.
if [[ ! $(lxc exec "$NAME" -- grep dulu /etc/passwd) ]]; then
    echo "Creating $DULU_USER user..."
    lxc exec "$NAME" -- adduser --gecos 'Dulu,,,' --disabled-login --uid 1999 $DULU_USER
    lxc exec "$NAME" -- adduser $DULU_USER adm
    lxc exec "$NAME" -- adduser $DULU_USER sudo
    # Set 1-time password if not already set (status=P if set).
    status=$(lxc exec "$NAME" -- passwd --status $DULU_USER | awk '{print $2}')
    if [[ $status != P ]]; then
        echo -e 'password\npassword' | lxc exec "$NAME" -- passwd $DULU_USER
        # Force password to expire immediately.
        lxc exec "$NAME" -- passwd -e $DULU_USER
    fi
fi

# Login to dulu user.
echo "The $NAME instance has been setup."
echo "After login, to setup or update dulu use dulu-server-setup.sh from:"
echo "$DULU_USER@$NAME:~\$ git clone https://github.com/n8marti/dulu.git"
echo "Logging in..."
lxc exec "$NAME" -- sudo --login --user "$DULU_USER"

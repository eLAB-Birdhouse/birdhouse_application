#!/bin/bash
# [ "$EUID" -eq 0 ] || exec sudo "$0" "$@" && echo -n "sudo bash what: "
# read WHAT
# sudo $WHAT
if [ "$EUID" != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Update and upgrade packages
sudo apt update
sudo apt upgrade -y

# Install needed packages and python3 modules
sudo apt install nginx python3 python3-pip -y
sudo python3 -m pip install flask uwsgi -U

# Create installation directory
sudo mkdir /etc/elab_birdhouse/
sudo chown www-data /etc/elab_birdhouse/
cd /etc/elab_birdhouse/

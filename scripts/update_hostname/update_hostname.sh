#!/bin/sh

if [ $# -ne 1 ]; then
    exit 1
fi

sudo sed -i -e "s/localhost.localdomain/${1}/g" /etc/sysconfig/network
sudo reboot

#!/bin/sh

# 参考
# https://cloud.google.com/compute/docs/disks/add-persistent-disk

if [ $# -ne 1 ]; then
    exit 1
fi

if type yum >/dev/null 2>&1; then
    sudo yum install -y expect
elif type apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get -y install expect
fi

LANG=C
expect -c '
    spawn sudo fdisk /dev/sdb

    expect "Command*"
    send "n\r"

    expect "Command*"
    send "p\r"

    expect "Partition number*"
    send "1\r"

    expect "First cylinder*"
    send "\r"

    expect "Last cylinder*"
    send "\r"

    expect "Command*"
    send "w\r"
    sleep 5
'

sudo mkfs.ext4 -F -E lazy_itable_init=0 /dev/sdb1
sudo mkdir -p $1
sudo mount -o defaults /dev/sdb1 $1
sudo chmod a+w $1
echo "/dev/sdb1 ${1} ext4 defaults 1 1" | sudo tee -a /etc/fstab
sudo rm -rf ${1}/lost+found

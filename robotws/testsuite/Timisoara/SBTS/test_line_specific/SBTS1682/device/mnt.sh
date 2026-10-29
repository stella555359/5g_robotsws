#!/bin/bash
echo =======================================
# share2
echo "Mount share2"
if [ ! -d /media/share2-mnt ]; then
    echo "Creating /media/share2 directory"
    sudo mkdir -p /media/share2-mnt
    sudo chown ute:ute /media/share2-mnt
fi
 
if ! grep -q "/media/share2-mnt" /proc/mounts; then
    echo "Mounting to /media/share2-mnt"
    if sudo mount -t cifs //10.5.16.72/share2 /media/share2-mnt -o _netdev,noperm,username=nokiatm,nosuid,noexec,password="Aikontm2@"; then
        echo "Mounting /media/share2-mnt OK"
    else
        echo "Mounting /media/share2-mnt failed!!!"
    fi
fi
 
# logs2
echo "Mount logs2"
if [ ! -d /media/logs2-mnt ]; then
    echo "Creating /media/logs2-mnt directory"
    sudo mkdir -p /media/logs2-mnt
    sudo chown ute:ute /media/logs2-mnt
fi
 
if ! grep -q "/media/logs2-mnt" /proc/mounts; then
    echo "Mounting to /media/logs2-mnt/"
    if sudo mount -t cifs //10.5.16.76/logs2 /media/logs2-mnt -o _netdev,noperm,username=nokiatm,nosuid,noexec,password="Aikontm8*"; then
        echo "Mounting /media/logs2-mnt OK"
    else
        echo "Mounting /media/logs2-mnt failed!!!"
    fi
fi
 
# BuildShareTimi01
echo "Mount BuildShareTimi01"
if [ ! -d /media/BuildShareTimi01 ]; then
    echo "Creating /media/BuildShareTimi01 directory"
    sudo mkdir -p /media/BuildShareTimi01
    sudo chown ute:ute /media/BuildShareTimi01
fi
 
if ! grep -q "/media/BuildShareTimi01" /proc/mounts; then
    echo "Mounting to /media/BuildShareTimi01/"
    if sudo mount -t cifs //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01 -o _netdev,noperm,username=userbuild,nosuid,noexec,password="Aikon_123456*8"; then
        echo "Mounting /media/BuildShareTimi01 OK"
    else
        echo "Mounting /media/BuildShareTimi01 failed!!!"
    fi
fi

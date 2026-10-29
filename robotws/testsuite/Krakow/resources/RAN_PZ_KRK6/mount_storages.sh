#!/bin/bash
#
# Simple script to mount storage in SG6.
# Copyright: Nokia Networks
# Author: Marcin Wachacki
# Contact: Marcin Wachacki


#######################################
# Mounts network storage in current file system.
# Arguments:
#   Name of storage.
#   Entry for /etc/fstab file
# Outputs:
#   None
#######################################
function mount_storage() {
    local STORAGE_NAME=$1
    local ENTRY=$2

    echo "Mounting \"${STORAGE_NAME}\" storage... "

    sudo /bin/sh -c "mkdir -p /mnt/$STORAGE_NAME"

    if ! grep -Fxq "$ENTRY" /etc/fstab; then
      echo "Adding new entry to /etc/fstab file..."
      sudo /bin/sh -c "echo $ENTRY >> /etc/fstab;"
    fi

    sudo /bin/sh -c "mount -a /mnt/$STORAGE_NAME"

    if [[ ! -d "/home/ute/$STORAGE_NAME" ]]; then
      sudo /bin/sh -c "ln -s /mnt/$STORAGE_NAME /home/ute/$STORAGE_NAME"
    fi

    if [ -z "$(ls -A /home/ute/$STORAGE_NAME)" ]; then
      echo "FAILED"
      exit 1
    else
      echo "SUCCESS"
      exit 0
    fi
}


declare -A ARGUMENTS

if [[ $# -lt 6 ]]; then
  echo "Missing mandatory options. Type -h to check help."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--type)
      ARGUMENTS["type"]="$2"
      shift
      shift
      ;;
    -u|--username)
      ARGUMENTS["username"]="$2"
      shift
      shift
      ;;
    -p|--password)
      ARGUMENTS["password"]="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

case ${ARGUMENTS["type"]} in
  "pubs")
    mount_storage "pubs" "//10.83.200.250/project/pubs /mnt/pubs cifs user,username=${ARGUMENTS['username']},vers=3.0,password=${ARGUMENTS['password']},domain=KRK-NAS,uid=ute,gid=ute 0 0"
    ;;
  "syve")
    mount_storage "syve" "//10.83.176.100/shared /mnt/syve cifs user,username=${ARGUMENTS['username']},vers=3.0,password=${ARGUMENTS['password']},uid=ute,gid=ute 0 0"
    ;;
  *)
    echo "Unknown type of storage: ${ARGUMENTS["type"]}."
    exit 1
    ;;
esac

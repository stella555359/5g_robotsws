#!/bin/bash

# Script consists of the following steps:
#
# [Step 1]
# Unmount "burak" resources and remove existing symbolic links and mount points.
# (Case 1) Existing "burak" resources are mounted:
# - burak resources are unmounted
# - all symbolic links on the Desktop are deleted
# - all mount points are deleted
# (Case 2) No "burak" resources are mounted
# - all symbolic links on the Desktop are deleted if exist
# - all mount points are deleted if exist
#
# [Step 2]
# Check for "burak" resource entries in /etc/fstab.
# If such entry exist, it will be deleted.
#
# [Step 3]
# New "burak" mount points are created:
# /media/burak
# /media/burak_siso
#
# [Step 4]
# New symbolic link are created on the Desktop to the \"burak\" resources..."
# /home/ute/Desktop/burak -> /media/burak
# /home/ute/Desktop/burak_siso -> /media/burak_siso
#
# [Step 5]
# New entries are added to the /etc/fstab file to automount "burak" resources.
#
# [Step 6]
# All "burak" resources referenced in /etc/fstab file are mounted to the following mount points:
# /media/burak
# /media/burak_siso

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INFO="${GREEN}(Info)${NC}"
WARNING="${YELLOW}(Warning)${NC}"
ERROR="${RED}(Error)${NC}"
DONE="${GREEN}[done]${NC}"
FAIL="${RED}[fail]${NC}"

#--------------------------------- [Step 1] --------------------------------------------

echo -e "\n${BLUE}[Step 1]${NC} Existing mounts checking ..."
mount_points=`mount | grep 10.42.248.45 | cut -d" " -f3`
mount_count=`mount | grep 10.42.248.45 | cut -d" " -f3 | wc -l`

# (Case 1) Existing "burak" resources are mounted
if [ $mount_count -gt 0 ]
then
    echo -e "${INFO} The following \"burak\" resources are mounted to the folders:"
    mount | grep 10.42.248.45 | cut -d" " -f1-3

    # Unmount existing "burak" resources
	for mount_point in $mount_points
	do
		sudo umount $mount_point 2>/tmp/mount_err
        if [ $? -ne 0 ]
        then
            echo -e "${ERROR} `cat /tmp/mount_err` ${FAIL}"
            rm -f /tmp/mount_err
            echo -e "${ERROR} Existing \"burak\" resources $mount_point has not been unmounted ${FAIL}"
        else
            echo -e "${INFO} Existing \"burak\" resource $mount_point has been unmounted ${DONE}"
        fi
    done

    mounts_count=`mount | grep 10.42.248.45 | cut -d" " -f3 | wc -l`
    if [ $mounts_count -eq 0 ]
    then
        echo -e "${INFO} All existing \"burak\" resources have been unmounted ${DONE}"
    else
        echo -e "${WARNING} Not all existing \"burak\" resources have been unmounted"
        echo -e "${WARNING} Fix this problem and run the script again !!!"
        exit 0
    fi

    # Delete existing symbolic links
    symlinks_count=`find /home/ute/Desktop -name "*burak*" -type l | wc -l`
    if [ $symlinks_count -gt 0 ]
    then
        echo -e "${INFO} The following symbolic links to \"burak\" resources exist on the Desktop:"
        ls -l /home/ute/Desktop/*burak* | cut -d" " -f9-
        find /home/ute/Desktop -name "*burak*" -type l -delete
        echo -e "${INFO} Existing symbolic links to \"burak\" resources on the Desktop have been deleted ${DONE}"
    else
        echo -e "${INFO} There are no existing symbolic links to \"burak\" resources on the Desktop"
    fi
    
    # Delete existing mount points
    echo -e "${INFO} The following \"burak\" mount points exist:"
	for mount_point in $mount_points
    do
        echo $mount_point
	done
    for mount_point in $mount_points
	do
        folders_count=`ls -A $mount_point | wc -l`
        if [ $folders_count -eq 0 ]
        then
    	    sudo rmdir $mount_point
            if [ $? -eq 0 ]
            then
                echo -e "${INFO} Existing \"burak\" mount point $mount_point has been deleted ${DONE}"
            else    
                echo -e "${ERROR} `cat /tmp/rmdir_err` ${FAIL}"
                echo -e "${ERROR} Existing mount point $mount_point has not been deleted ${FAIL}"
                echo -e "${WARNING} Fix this problem and run the script again !!!"
                rm -f /tmp/rmdir_err
                exit 0
            fi
        else
            echo -e "${ERROR} Existing mount point $mount_point cannot be deleted. Folder $mount_point is no empty ${FAIL}" 
            echo -e "${WARNING} Fix this problem and run the script again !!!"
            exit 0
        fi
    done
#    echo -e "${INFO} All existing \"burak\" mount points have been deleted"

# (Case 2) No "burak" resources are mounted
else
    echo -e "${INFO} There are no existing \"burak\" mounted resources"
    
    # Delete existing symbolic links if exists
    symlinks_count=`find /home/ute/Desktop -name "*burak*" -type l | wc -l`
    if [ $symlinks_count -gt 0 ]
    then
        echo -e "${INFO} The following symbolic links to \"burak\" resources exist on the Desktop:"
        ls -l /home/ute/Desktop/*burak* | cut -d" " -f9-
        find /home/ute/Desktop -name "*burak*" -type l -delete
        echo -e "${INFO} Existing symbolic links to \"burak\" resources on the Desktop have been deleted ${DONE}"
    else
        echo -e "${INFO} There are no existing symbolic links to \"burak\" resources on the Desktop"
    fi
    
# Delete existing mount points
    folders_count=`ls -d /media/*burak* 2> /dev/null | wc -l`
    if [ $folders_count -gt 0 ]
    then
        echo -e "${INFO} The following \"burak\" mount points exist:"
        ls -d1 /media/*burak*
        mount_folders=`ls -d /media/*burak*`
	    for mount_folder in $mount_folders
	    do
            folders_count=`ls -A $mount_folder | wc -l`
            if [ $folders_count -eq 0 ]
            then
    	        sudo rmdir $mount_folder
                if [ $? -eq 0 ]
                then
                    echo -e "${INFO} Existing \"burak\" mount point $mount_folder has been deleted ${DONE}"
                else
                    echo -e "${ERROR} `cat /tmp/rmdir_err` ${FAIL}"
                    echo -e "${ERROR} Existing mount point $mount_folder has not been deleted ${FAIL}"
                    echo -e "${WARNING} Fix this problem and run the script again !!!"
                    rm -f /tmp/rmdir_err
                    exit 0
                fi
            else
                echo -e "${ERROR} Existing mount point $mount_folder cannot be deleted. Folder $mount_folder is no empty ${FAIL}" 
                echo -e "${WARNING} Fix this problem and run the script again !!!"
                exit 0
            fi
        done
    else
        echo -e "${INFO} There are no existing \"burak\" mount points"
    fi
fi

#--------------------------------- [Step 2] --------------------------------------------

echo -e "\n${BLUE}[Step 2]${NC} File system table configuration file checking (old entries) ..."
fstab_elements=`grep 10.42.248.45 /etc/fstab | wc -l`

if [ $fstab_elements -gt 0 ]
then
    sudo sed -i '/burak/d' /etc/fstab
    sudo sed -i '/^$/d' /etc/fstab
    echo -e "${INFO} All \"burak\" entries in the configuration file have been removed ${DONE}"
else
    echo -e "${INFO} There are no \"burak\" entries in the configuration file"
fi

#--------------------------------- [Step 3] --------------------------------------------

echo -e "\n${BLUE}[Step 3]${NC} Mount points creating ..."
sudo mkdir /media/burak 2> /dev/null
sudo mkdir /media/burak_siso 2> /dev/null
echo -e "${INFO} The following mount points have been created: ${DONE}"
ls -1d /media/burak*

#--------------------------------- [Step 4] --------------------------------------------

echo -e "\n${BLUE}[Step 4]${NC} Symbolic link creating ..."
ln -s /media/burak /home/ute/Desktop/burak 2> /dev/null
ln -s /media/burak_siso /home/ute/Desktop/burak_siso 2> /dev/null
echo -e "${INFO} The following symbolic link have been created on the Desktop to the \"burak\" resources: ${DONE}"
ls -l /home/ute/Desktop/burak* | cut -d" " -f9-

#--------------------------------- [Step 5] --------------------------------------------

echo -e "\n${BLUE}[Step 5]${NC} File system table configuration file updating ..."
sudo echo -e "\n#burak IAV" >> /etc/fstab
sudo echo '//10.42.248.45/IAV_WCDMA /media/burak cifs domain=intra.noklab.net,user=plwrranpz4,password=Ut3pa5s#1be1,vers=3.0,rw,nounix,file_mode=0777,dir_mode=0777,_netdev 0 0' >> /etc/fstab
sudo echo -e "#burak SISO" >> /etc/fstab
sudo echo '//10.42.248.45/Global_veryfication /media/burak_siso cifs domain=intra.noklab.net,user=plwrranpz4,password=Ut3pa5s#1be1,vers=3.0,rw,nounix,file_mode=0777,dir_mode=0777,_netdev 0 0' >> /etc/fstab
echo -e "${INFO} All entries for \"burak\" have been added to the file system table configuration file ${DONE}"

#--------------------------------- [Step 6] --------------------------------------------

echo -e "\n${BLUE}[Step 6]${NC} Remote resources mounting ..."
sudo mount -a
echo -e "${INFO} The remote resources are mounting. Please wait a minute ..."
echo -e "${INFO} The following \"burak\" resources have been mounted: ${DONE}"
mount | grep 10.42.248.45 | cut -d" " -f1-3
echo
echo -e "${INFO} All successfully configured"
echo -e "${INFO} Check if you have access to the mounted \"burak\" resources:"
ls -1d /media/burak*
echo

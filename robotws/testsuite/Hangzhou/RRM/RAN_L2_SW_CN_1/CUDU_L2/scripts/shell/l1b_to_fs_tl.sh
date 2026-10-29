#!/bin/bash

echo "**********Start to execute l1b_to_fs_gnb.sh**********"
sshpass -p oZPS0POrRieRtu scp -q  ./l1b_to_fs_gnb.sh  toor4nsn@192.168.255.1:/user/toor4nsn
sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'sh l1b_to_fs_gnb.sh'


echo "**********Start to execute l1b_to_fs_ap.sh**********"
sshpass -p oZPS0POrRieRtu scp -q  ./l1b_to_fs_ap.sh  toor4nsn@192.168.200.1:/user/toor4nsn
sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sh l1b_to_fs_ap.sh'

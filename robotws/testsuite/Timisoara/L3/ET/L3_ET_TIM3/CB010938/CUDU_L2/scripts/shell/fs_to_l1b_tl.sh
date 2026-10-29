#!/bin/bash

echo "**********Start to execute fs_to_l1b_gnb.sh**********"
sshpass -p oZPS0POrRieRtu scp -q  ./fs_to_l1b_gnb.sh  toor4nsn@192.168.255.1:/user/toor4nsn
sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'sh fs_to_l1b_gnb.sh'

echo "**********Start to execute fs_to_l1b_ap.sh***********"
sshpass -p oZPS0POrRieRtu scp -q  ./fs_to_l1b_ap.sh  toor4nsn@192.168.200.1:/user/toor4nsn
sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'sh fs_to_l1b_ap.sh'
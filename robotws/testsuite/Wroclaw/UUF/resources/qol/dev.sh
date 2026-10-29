#!/bin/bash
git -C /home/ute/MN/UTE/robotws remote remove origin
git -C /home/ute/MN/UTE/robotws remote add origin https://wrgitlab.ext.net.nokia.com/RAN/robotws.git
git -C /home/ute/MN/UTE/robotws config credential.helper 'cache --timeout=28800'
git -C /home/ute/MN/UTE/robotws config --global core.mergeoptions --no-edit
cd /home/ute/MN/UTE/robotws
echo 'You can now checkout all branches. Use following command to synchronize with your branch:'
echo 'git pull origin YOUR_BRANCH_NAME'
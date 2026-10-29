#!/bin/bash
# Author: Bartlomiej Kukla
# Email:  bartlomiej.kukla@nokia.com

mkdir /home/ute/MN/UTE/robotlte
cd /home/ute/MN/UTE/robotlte

git init
git remote remove origin
git remote add origin https://devkr:bL_5FXW7sTK7Kkifp6dx@wrgitlab.int.net.nokia.com/RAN/robotlte;
git config core.sparseCheckout true
echo "/testsuite/WMP/DevKr/" >> .git/info/sparse-checkout
echo "/resources/DevKr/" >> .git/info/sparse-checkout
echo "/libraries/" >> .git/info/sparse-checkout
git pull origin master --no-edit;
git fetch;
git branch -v -a | grep devkr | awk "{print \$1}" | sed "s/remotes\/origin\///"

cp /home/ute/MN/UTE/robotlte/resources/DevKr/CRT/bash_aliases /home/ute/.bash_aliases
source .bash_aliases
/home/ute/MN/UTE/robotlte/resources/DevKr/prepare_testline.sh

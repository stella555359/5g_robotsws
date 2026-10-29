#!/bin/bash
(
echo "**********************************************"
echo "$(date) : Installation - start"
echo "**********************************************"
#ute_versions
echo "**********************************************"
export PIP_CONFIG_PATH=$HOME/.pip/pip.conf.generic;
if [ ! -e "$PIP_CONFIG_PATH" ]; then printf "[global]
index-url = https://artifactory-espoo2.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple
disable-pip-version-check = True" > $PIP_CONFIG_PATH;fi;
cd $HOME; /usr/bin/rm -fr test_repo test_repository $HOME/MN/UTE/robotws
/usr/bin/mkdir -p $HOME/MN/UTE/robotws; /usr/bin/ln -s $HOME/MN/UTE/robotws test_repository
echo "********************************************** repository clone"
git clone --progress git@wrgitlab.ext.net.nokia.com:RAN/robotws.git $HOME/MN/UTE/robotws
echo "********************************************** Virtual environement creation"
/opt/ute/python3/bin/pip install -U ute_syslog
/opt/ute/python3/bin/python3 -m venv test_repo
source /home/ute/test_repo/bin/activate; pip install -U pip; pip install -U -r $HOME/test_repository/requirements.cfg;sudo apt-get update ;sudo apt-get install ute-node 
res=`cat /home/ute/.bash_profile | grep node`
[ "$res" = "" ] && echo "export PATH=$PATH:/opt/ute/node" >> /home/ute/.bash_profile
echo "**********************************************"
#ALG  test
#sudo rm -rf /tmp/*
df -h
echo "**********************************************"
echo "$(date) : Installation - End"
echo "**********************************************"
) 2>&1 | tee $HOME/Installation_ute_env.log

#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

rm $WTS_PATH
ln -s /opt/iphy/latest $WTS_PATH

chmod 777 $WTS_PATH/startWTS.sh
sed -i 's/egate --port 30000 --root/egate --port 20000 --root/g' $WTS_PATH/startWTS.sh
sed -i '/WORK_DIR=$(dirname $0)/a cd $WORK_DIR' $WTS_PATH/startWTS.sh

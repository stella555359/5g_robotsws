#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh
SMOD_ASIL="ASIL"

rm $WTS_PATH
ln -s /opt/iphy/latest $WTS_PATH

if [[ "$1" == "$SMOD_ASIL" ]]; then
  cp $RESOURCES_PATH/epc_abip.lua $WTS_PATH/epc.lua
  cp $RESOURCES_PATH/cus_abip.ini $WTS_PATH/cus.ini
  cp $RESOURCES_PATH/epc.sh $WTS_PATH
  echo "Simulator configuration files successfully copied."
elif [[ "$1" == "ASOE" ]] && [[ "$2" == "FDD" ]]
 then
    cp $RESOURCES_PATH/epc_asoe_fdd.lua $WTS_PATH/epc.lua
    cp $RESOURCES_PATH/cus_asoe_fdd.ini $WTS_PATH/cus.ini
    cp $RESOURCES_PATH/epc.sh $WTS_PATH
    sudo cp $RESOURCES_PATH/ue.db /opt/cus/etc/
    echo "Simulator configuration files successfully copied."
elif [[ "$1" == "ASOE" ]] && [[ "$2" == "TDD" ]]
then
    cp $RESOURCES_PATH/epc_asoe_tdd.lua $WTS_PATH/epc.lua
    cp $RESOURCES_PATH/cus_asoe_tdd.ini $WTS_PATH/cus.ini
    cp $RESOURCES_PATH/epc.sh $WTS_PATH
    sudo cp $RESOURCES_PATH/ue.db /opt/cus/etc/
    echo "Simulator configuration files successfully copied."
elif [[ "$1" == "ASIB" ]]
then
    cp $RESOURCES_PATH/epc_asib.lua $WTS_PATH/epc.lua
    cp $RESOURCES_PATH/cus_asib.ini $WTS_PATH/cus.ini
    cp $RESOURCES_PATH/epc.sh $WTS_PATH
    sudo cp $RESOURCES_PATH/ue.db /opt/cus/etc/
    echo "Simulator configuration files successfully copied."
else
  cp $RESOURCES_PATH/epc.lua $WTS_PATH
  cp $RESOURCES_PATH/cus.ini $WTS_PATH
  cp $RESOURCES_PATH/epc.sh $WTS_PATH
  echo "Simulator configuration files successfully copied."
fi

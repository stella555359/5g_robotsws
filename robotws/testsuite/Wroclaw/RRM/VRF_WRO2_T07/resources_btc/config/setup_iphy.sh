DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

IPHY_CONFIG_PATH=$RESOURCES_PATH/$1
IPHY_CONFIG=`cd $IPHY_CONFIG_PATH; find iphy*.xml`
python $DIR/iphy_config_update.py $IPHY_CONFIG_PATH/$IPHY_CONFIG && \

sshpass -p $PASSWORD scp $IPHY_CONFIG_PATH/$IPHY_CONFIG $USERNAME@$IPHY_IP:/flash/simmode/ && \
sshpass -p $PASSWORD ssh $USERNAME@$IPHY_IP "cd /flash/simmode/; rm iphy.xml; ln -s $IPHY_CONFIG iphy.xml" && \
sshpass -p $PASSWORD ssh $USERNAME@$IPHY_IP "reboot"

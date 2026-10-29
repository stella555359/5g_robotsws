DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

rm $WTS_PATH
ln -s /opt/iphy/latest $WTS_PATH

cp $RESOURCES_PATH/fsyslog $WTS_PATH
cp $RESOURCES_PATH/1enb*.lua $WTS_PATH
cp $RESOURCES_PATH/epc.sh $WTS_PATH

$WTS_PATH/epc.sh start

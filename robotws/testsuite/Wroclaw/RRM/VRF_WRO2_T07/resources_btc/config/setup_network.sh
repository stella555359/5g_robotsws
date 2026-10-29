DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

NETWORK_CONFIG=/etc/network/interfaces

if ! grep 'EGATE' ${NETWORK_CONFIG} > /dev/null
then
    sudo chmod 777 ${NETWORK_CONFIG}
    cat ${DIR}/resources/interfaces >> ${NETWORK_CONFIG}
    sudo chmod 644 ${NETWORK_CONFIG}
fi

sudo /etc/init.d/networking restart > /dev/null

/sbin/ifconfig -a | grep -P -o 'v?eth(?!er)\w+(?=:)' | \
while read INTERFACE
do
    sudo /sbin/ifconfig $INTERFACE up > /dev/null
done
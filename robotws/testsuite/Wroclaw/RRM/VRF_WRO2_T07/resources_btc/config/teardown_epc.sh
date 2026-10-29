DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

if [ -f ${WTS_PATH}/epc.sh ]
then
    ${WTS_PATH}/epc.sh stop
fi

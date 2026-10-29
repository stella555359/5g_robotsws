DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

cp ${FTTOOLS_PATH}/Logs/*.zip $1

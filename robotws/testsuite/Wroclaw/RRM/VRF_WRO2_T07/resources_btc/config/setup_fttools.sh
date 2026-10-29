DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

rm -r -f $FTTOOLS_PATH
git clone https://gitlab+deploy-1:gldt-LAV3jijnoM-6oGhXFtEo@gitlabe1.ext.net.nokia.com/LOM/FTTools.git -b $1 $FTTOOLS_PATH

TESTLINE=`hostname | tr - _`
CLASS=`hostname | sed -r "s/IAV-\w+-//"`
sed $FTTOOLS_PATH/config.py -i -e "s/UTECloud/${CLASS}/"

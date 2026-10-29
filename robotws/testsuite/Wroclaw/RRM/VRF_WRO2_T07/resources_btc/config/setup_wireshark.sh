DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

mkdir -p ~/.wireshark; mkdir -p ~/.config/wireshark
cp $RESOURCES_PATH/wireshark_preferences ~/.config/wireshark/preferences
cp $RESOURCES_PATH/wireshark_sslkey_lte ~/.config/wireshark/ssl_keys

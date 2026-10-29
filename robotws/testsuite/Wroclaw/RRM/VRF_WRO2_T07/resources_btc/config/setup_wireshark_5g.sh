DIR="$(cd "$(dirname "$0")" && pwd)" && . ${DIR}/config.sh

mkdir -p ~/.wireshark; mkdir -p ~/.config/wireshark
cp $RESOURCES_PATH/wireshark_preferences_5g ~/.config/wireshark/preferences
cp $RESOURCES_PATH/wireshark_sslkey_5g ~/.config/wireshark/ssl_keys

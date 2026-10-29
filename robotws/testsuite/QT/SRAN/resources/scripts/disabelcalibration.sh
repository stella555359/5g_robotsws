#!/bin/busybox sh

frmon_file="/tmp/frmon_connect"

printf '/ action create ConfigAccess /ca /module\n/ca action fetch DECODED "type/raaca_config.bin" "/tmp/raaca_config.json"\n' > $frmon_file
frmonShellClient 127.0.0.1 2000 $frmon_file

sed 's/"seconds": 50/"seconds": 50000/' /tmp/raaca_config.json > /tmp/new_raaca_config.json

printf '/ca action store PERMANENT DECODED "type/raaca_config.bin" "/tmp/new_raaca_config.json"\n/ca action terminate\n' > $frmon_file
frmonShellClient 127.0.0.1 2000 $frmon_file

rm /tmp/new_raaca_config.json
rm /tmp/raaca_config.json
rm /tmp/frmon_connect

exit 0


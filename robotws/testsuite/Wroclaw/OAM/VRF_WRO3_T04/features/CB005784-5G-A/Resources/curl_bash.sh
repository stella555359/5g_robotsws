#!/bin/bash

output=$(curl -i -s -k -X $'POST' \
    -H $'Host: 192.168.255.129' -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0' -H $'Accept: */*' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'X-Requested-With: XMLHttpRequest' -H $'Content-Type: application/json' -H $'Content-Length: 120' -H $'Origin: https://192.168.255.129' -H $'Connection: close' -H $'Referer: https://192.168.255.129/' \
    --data-binary $'{\"login\":\"Nemuadmin\",\"token\":\"nemuuser\",\"originator\":\"WEB_EM\",\"authMethod\":\"LOGIN_BASED\",\"readOnlyAccessRequired\":false}' \
    $'https://192.168.255.129/LoginRequest')

echo $output

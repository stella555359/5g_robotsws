#!/bin/bash
netopeer2-cli <<END
connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem  
get --out /home/ute/oran_alarm_list_via_script.txt
get-config --source running --out /home/ute/get_config
disconnect
END
echo ""
exit 0


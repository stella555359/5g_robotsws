*** Settings ***
Documentation
...     description:    Keywords for test cases for the 5GC002284 feature.

Library          lldp_functions.py

*** Keywords ***
Configure LLDP obj
    ${connection}=  Connect to admin
    create_lldp_ethapp_object  connection=${connection}
    create_lldp_object  connection=${connection}
    [Teardown]                          run keyword
                                        ...  Disconnect from admin

Check if MAC addres and port ID are correct
    ${connection}=  Connect to admin
    ${portID}=  get_portid_webem  ${connection}
    ${chassisID}=  get_chassisid_webem  ${connection}
    ${ssh_conn}=    Connect to BTS
    check_if_mac_portid_match  ${chassisID}  ${portID}  ${TOPOLOGY}    ${ssh_conn}
    [Teardown]    Run Keyword And Ignore Error    Disconnect from admin

Connect to PestTC and send rate limiting packets
    send_pcap_via_tcpreplay  5000  /home/r00t/LLDP_Testing/lldp_rate_limiting.pcap

Connect to PestTC and send different TLVS packets
    send_pcap_via_tcpreplay  3500  /home/r00t/LLDP_Testing/lldp_different_tlvs.pcap

Activities on LLDP object from gNB ASIL
    ${connection}=  Connect to admin
    switch_lldp_operation  no disable  ASIL
    activity_lldp_object  ${connection}  update
    sniffing_lldp_disable_packet
    log to console  Start Sniffing LLDP packets
    sleep  50
    activity_lldp_object  ${connection}  delete
    [Teardown]  run keywords  activity_lldp_object  ${connection}  create  AND
    ...    Disconnect from admin

Activities on LLDP object from Switch
    ${connection}=  Connect to admin
    switch_lldp_operation  disable  ASIK
    wait until keyword succeeds  5min  10s  get_lldp_r_neighbour  ${connection}  disable
    switch_lldp_operation  no disable  ASIK
    wait until keyword succeeds  1min  10s  get_lldp_r_neighbour  ${connection}  no disable
    [Teardown]  run keywords  switch_lldp_operation  no disable  ASIK     AND  Disconnect from admin

Check Mplane Pingability
    ${output}=  Run  ping -c 60 ${MPLANE_IPV4}
    Should Contain  ${output}  60 received


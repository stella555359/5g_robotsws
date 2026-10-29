*** Settings ***
Documentation
...                 test scenario author: Szymon Temecki
...                 contact: szymon.temecki@nokia.com
...                 test automation author: Patryk Brodziak, Bartosz Cieslik
...                 contact: patryk.brodziak@nokia.com, bartosz.cieslik@nokia.com

Resource  ../resources/Keywords.robot
Resource  ../../../common_resources/connections/connections.robot
Library  ../resources/lldp_functions.py

*** Keywords ***
5GC002284_LLDP_Network_discovery_table_verification
    Configure LLDP obj
    Sleep  30s
    Connect to BTS
    Check if MAC addres and port ID are correct
    [Teardown]  Disconnect from BTS

5GC002284_LLDP_ingress_rate_limiting
    Connect to BTS
    Connect to PestTC and send rate limiting packets
    check_lldp_processes
    Check Mplane Pingability
    [Teardown]  Disconnect from BTS

5GC002284_LLDP_Various_Ethernet_TLVs
    Connect to BTS
    Connect to PestTC and send different TLVS packets
    check_lldp_processes
    Check Mplane Pingability
    [Teardown]  Disconnect from BTS

5GC002284_LLDP_Disable_from_gNb
    Connect to BTS
    Activities on LLDP object from gNB ASIL
    [Teardown]  Disconnect from BTS

5GC002284_LLDP_Disable_from_switch
    Connect to BTS
    Activities on LLDP object from Switch
    [Teardown]  Disconnect from BTS


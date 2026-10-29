*** Settings ***
Documentation
...    author: Jakub Kupiec
...    contact: jakub.kupiec@nokia.com
...    Description: Test Cases 5GC001580-BA

Library     testsuite/Krakow/TRS/resources/ipsec/ipsec_keywords.py
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASOD_AEUD_ENB
...           CRT__WITH__RAN_5G_TDD_MP__WITH__pDU22R2

Suite Setup       Common Suite Setup With Commissioning    prefix_tag=IPSEC
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Test Cases ***
[1][1.0] 5GC000392-B_26_IPsec_Commissioning
    Check if ipsec is up

[1]5GC000392-B_04_IPsec_DPD_Nominal_Behavior
    Check if ipsec is up
    Block link between du and secGW
    Wait until keyword succeeds    5min     10 sec     Check if DPD alarm is active
    Unblock link between du and secGW
    Wait until keyword succeeds    5min     10 sec     Check if DPD alarm is inactive

[1]5GC000392-B_07_IPsec_DSCP_Management_ISAKMP
    Check if ipsec is up
    Change DSCP parameter    value=26
    Check if ipsec is up
    Verify DSCP value in IP header ISAKMP   expected_value=26

[1]5GC000392-B_08_IPsec_DSCP_Management_ESP
    Check if ipsec is up
    Verify if traffic with fragmentation is encrypted
    Verify if DSCP value is same in encrypted and non encrypted IP header

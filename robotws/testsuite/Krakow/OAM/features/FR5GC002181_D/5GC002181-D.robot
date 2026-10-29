*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    XML    use_lxml=True
Library    taf.gnb.oam.coam.admin   WITH NAME   admin
Library    taf.transport.ssh    WITH NAME    ssh
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC002550_ASOD/resources/5GC002550_ASOD_CommonKeywords.robot
Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC002550_ASOD/resources/ConnectivityKeywords.robot
Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC002550_ASOD/resources/Basic_Keywords.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    CDRT   RAN_5G_MP
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6__WITH__CRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6__WITH__CRT
...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6__WITH__CRT
...           SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6__WITH__CRT

Suite Setup       Run Keywords
...                  Common Suite Setup With Commissioning
...                  ADMIN connection
Suite Teardown    Run Keywords
...                  ADMIN disconnection
...                  Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
@{additional_allowed_alarms} =  Automatic BTS Operator Certificate retrieval unsuccessful

*** Test Cases ***
[1]5GC002181-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(dynamic_data)
    wait until keyword succeeds    3x    120s    Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_SMOD(dynamic_data)

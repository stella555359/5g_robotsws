*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASOD_AEUD_ENB
...           CRT__WITH__RAN_5G_TDD_MP__WITH__pDU22R2

Suite Setup       Common Suite Setup With Commissioning    prefix_tag=NEA2
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
${capabilities_ue}   REAL_UE
${branch_tag}        None
${size_packet}         1400B
${dl_size_packet}      1400B
${ul_size_packet}      1000B
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    2M
${buffer_server_ul}    2M
${interval}            1
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

*** Test Cases ***
[1][1.0] General_SiSo_Antenna_Carrier_Configuration_OTA
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=2242 Mbits/sec
    ...    parallel_streams_dl=4
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True

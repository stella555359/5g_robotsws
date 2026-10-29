*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     testsuite/Krakow/Cloud/resources/TsharkKeywords.py

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
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    2M
${buffer_server_ul}    2M
${interval}            1
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

*** Test Cases ***
[1]5GC002241_BA_102_5GC000475_B_ Successful SgNB Addition with continuous DL data transmission from 4G to 5G ASOD
    start_traffic_sniffers
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=10s    tput=300 Mbits/sec    protocol=udp    deviation=13%
    ...    parallel_streams=1    size_packet=${size_packet}    buffer_client=${buffer_client_dl}
    ...    buffer_server=${buffer_server_dl}    interval=${interval}
    stop_traffic_sniffers_and_collect_results
    Check SgNB Addition

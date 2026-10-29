*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     testsuite/Krakow/Cloud/resources/TsharkKeywords.py
Library     testsuite/Krakow/Cloud/resources/ClassicalX2Sniffer.py
Library     taf.ul.hanging_resources.listener    fail_on_not_released_resources=${False}

Force Tags    STATE_SW_UPLOADED    RAN_5G   CDRT    RAN_5G_MP
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUB__WITH__CRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUB__WITH__CRT

Suite Setup       Common Suite Setup With Commissioning
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
[1]5GC001581_BA_102_5GC000475_B_ Successful SgNB Addition with continuous DL data transmission from 4G to 5G ASIK_ABIL
    start_x2_collection
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=10s    tput=300 Mbits/sec    protocol=udp    deviation=13%
    ...    parallel_streams=1    size_packet=${size_packet}    buffer_client=${buffer_client_dl}
    ...    buffer_server=${buffer_server_dl}    interval=${interval}
    stop_x2_collection_and_download_pcap
    Check SgNB Addition

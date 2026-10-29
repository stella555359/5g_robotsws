*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     testsuite/Krakow/Cloud/resources/TsharkKeywords.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_QC_ASIKR_ABILB4_AEUB
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
[1]5GC001573_KA_07_5GC000543_B_023_Simultaneous_UL_and_DL_data_traffic_using_NEA2_algorithm
    start_traffic_sniffers
    Run Keyword And Continue On Failure    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}
    ...    duration=10s    tput_dl=200 Mbits/sec    parallel_streams_dl=1    tput_ul=100 Mbits/sec
    ...    parallel_streams_ul=1    protocol=udp    deviation=30%    size_packet=${size_packet}
    ...    buffer_client_dl=${buffer_client_dl}    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}    interval=${interval}
    stop_traffic_sniffers_and_collect_results
    Check NEA    2
    check_dl_traffic     data_ciphered=True
    check_ul_traffic     data_ciphered=True

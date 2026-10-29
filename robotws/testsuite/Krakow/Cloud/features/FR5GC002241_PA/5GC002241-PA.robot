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

Suite Setup       Common Suite Setup With Commissioning    prefix_tag=DRX
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
[1]5GC002241_PA_5_NSA-cloud-mmw-TDD-ASIK_cDRX_DL_Trafic
    start_traffic_sniffers
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=100s    protocol=udp    deviation=13%
    ...    tput=561 Mbits/sec
    ...    parallel_streams=1
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    stop_traffic_sniffers_and_collect_results
    Check SgNB Addition
    Check long DRX cycle
    Validate DRX counters are correctly managed


[1]5GC002241_PA_6_NSA-cloud-mmw-TDD-ASIK_cDRX_UL_Trafic
    start_traffic_sniffers
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=100s    protocol=udp    deviation=13%
    ...    tput=138 Mbits/sec
    ...    parallel_streams=1
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    stop_traffic_sniffers_and_collect_results
    Check SgNB Addition
    Check long DRX cycle
    Validate DRX counters are correctly managed

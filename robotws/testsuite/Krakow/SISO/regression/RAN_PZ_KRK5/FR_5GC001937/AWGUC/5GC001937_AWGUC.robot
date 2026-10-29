*** Settings ***
Documentation
...   Test suite for regression testing of feature 5GC001937
...   author: Radoslaw Serafin
...   contact: radoslaw.serafin@nokia.com


Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/DL_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/UL_Throughput_1-DRB_OTA/procedure.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    taf.ul.hanging_resources.listener    ${False}


Force Tags    STATE_SW_UPLOADED    CDRT    CRT    CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AWGUC

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${capabilities}    REAL_UE
${duration}    300s
${duration_8CC_1-DRB}    1200s
${deviation}     10%
${deviation_3cc_tcp_dl}               4.5%
${size_packet_dl}    1400B
${size_packet_ul}    1320B
${buffer_client_dl_udp}    8M
${buffer_server_dl_udp}    8M
${buffer_client_ul_udp}    2M
${buffer_server_ul_udp}    2M
${tput_ul}    245 Mbits/sec
${parallel_streams_ul}    2
${interval}    1
${reboot_ue}    True
${timeout_reboot_ue}    100
${linux_congestion}    reno
${current_config}    None
${COLLECT_LOGS_DURING_DATA_TRANSFER}  False

*** Test Cases ***
[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWGUC_3CC_contiguous
    [Tags]    RAN_5G_MP__WITH__SBTS22R3
    ...       RAN_5G__WITH__SBTS22R4
    ...       RAN_5G__WITH__SBTS23R1
    ...       RAN_5G__WITH__SBTS00
    [Setup]    Common Preconditions With Commissioning    3CC
    [Timeout]    30m
    Set Test Variable    ${protocol}                  tcp
    Set Test Variable    ${tput_dl}                   1530 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_tcp}   2

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_3cc_tcp_dl}    deviation_ul=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl_tcp}    parallel_streams_ul=${parallel_streams_ul}    size_packet_dl=${size_packet_dl}
    ...    size_packet_ul=${size_packet_ul}    interval=${interval}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    ...    linux_congestion_dl=${linux_congestion}


[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWGUC_4CC_contiguous
    [Tags]    RAN_5G_MP__WITH__SBTS22R3
    ...       RAN_5G__WITH__SBTS22R4
    ...       RAN_5G__WITH__SBTS23R1
    ...       RAN_5G__WITH__SBTS00
    [Setup]    Common Preconditions With Commissioning    4CC
    [Timeout]    35m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}    2170 Mbits/sec
    Set Test Variable    ${parallel_streams_dl}    2

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}     duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation=${deviation}     parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    size_packet=${size_packet_dl}    interval=${interval}
    ...    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    linux_congestion_dl=${linux_congestion}


[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWGUC_8CC_contiguous
    [Tags]    RAN_5G_MP__WITH__SBTS22R3
    ...       RAN_5G__WITH__SBTS22R4
    ...       RAN_5G__WITH__SBTS23R1
    ...       RAN_5G__WITH__SBTS00
    [Setup]    Common Preconditions With Commissioning    8CC
    [Timeout]    55m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}    4340 Mbits/sec
    Set Test Variable    ${parallel_streams_dl}    4

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}    duration=${duration_8CC_1-DRB}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}
    ...    interval=${interval}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    linux_congestion_dl=${linux_congestion}


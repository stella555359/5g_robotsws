*** Settings ***
Force Tags    PY36
Documentation
...   Test suite for regression testing of feature 5GC001937
...   author: Mateusz Jaskot
...   contact: mateusz.jaskot@nokia.com

Resource    ./Resources/Resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/DL_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/UL_Throughput_1-DRB_OTA/procedure.robot
Resource    taf/rfrl/bts/robot/common/gnb_ru.robot


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Common Test Teardown EP

*** Variables ***
@{allowed_alarms}                     SSH enabled
...                                   R&D Service Port enabled
...                                   LMP access via port 443
...                                   Diagnostic Files collected
...                                   Radio Diagnostic Files collected
...                                   BTS Reset Cause
...                                   Ethernet port security is disabled
...                                   Service account root access is enabled
...                                   Sanity Check Error
${capabilities}                       REAL_UE
${duration}                           300s
${deviation_4cc_udp_dl}               4.8%
${deviation_4cc_tcp_dl}               4.8%
${deviation_5cc_udp_dl}               4.3%
${deviation_5cc_tcp_dl}               4.3%
${deviation_6cc_udp_dl}               3.9%
${deviation_6cc_tcp_dl}               3.9%
${deviation_7cc_udp_dl}               2.57%
${deviation_7cc_tcp_dl}               2.57%
${parallel_streams_dl_udp}            3
${parallel_streams_dl_tcp}            3
${buffer_client_dl_udp}               4M
${buffer_server_dl_udp}               4M
${size_packet_dl}                     1400B
${size_packet_ul}                     1320B
${tput_ul}                            250 Mbits/sec
${deviation_ul}                       12%
${parallel_streams_ul}                2
${buffer_client_ul_udp}               2M
${buffer_server_ul_udp}               2M
${interval}                           1
${reboot_ue}                          ${TRUE}
${timeout_reboot_ue}                  100
${linux_congestion_protocol}          reno
${COLLECT_LOGS_DURING_DATA_TRANSFER}  False
${current_config}                     None

*** Test Cases ***
[1][1.0] UL_Throughput_TCP_1-DRB_OTA_AWEUC_4CC_contiguous
    [Setup]    Test Setup for Configuration EP    4CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp

    UL_Throughput_1-DRB_OTA     capabilities=${capabilities}
    ...                         duration=${duration_4cc}
    ...                         tput=${tput_ul}
    ...                         protocol=${protocol}
    ...                         deviation=${deviation_ul}
    ...                         parallel_streams=${parallel_streams_ul}
    ...                         size_packet=${size_packet_ul}
    ...                         interval=${interval}
    ...                         reboot_ue=${reboot_ue}
    ...                         timeout_reboot_ue=${timeout_reboot_ue}


[1][1.0] DL_Throughput_TCP_1-DRB_OTA_AWEUC_4CC_contiguous
    [Setup]    Test Setup for Configuration EP    4CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     2050 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration_4cc}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_4cc_tcp_dl}
    ...                        parallel_streams=${parallel_streams_dl_tcp}
    ...                        size_packet=${size_packet_dl}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}
    ...                        linux_congestion=${linux_congestion_protocol}

[1][1.0] DL_Throughput_UDP_1-DRB_OTA_AWEUC_4CC_contiguous
    [Setup]    Test Setup for Configuration EP    4CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}                  udp
    Set Test Variable    ${tput_dl}                   2050 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_udp}   2

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_4cc_udp_dl}
    ...                        parallel_streams=${parallel_streams_dl_udp}
    ...                        size_packet=${size_packet_dl}
    ...                        buffer_client=${buffer_client_dl_udp}
    ...                        buffer_server=${buffer_server_dl_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] UL_Throughput_UDP_1-DRB_OTA_AWEUC_4CC_contiguous
    [Setup]    Test Setup for Configuration EP    4CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        buffer_client=${buffer_client_ul_udp}
    ...                        buffer_server=${buffer_server_ul_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] DL_Throughput_TCP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     2550 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_5cc_udp_dl}
    ...                        parallel_streams=${parallel_streams_dl_tcp}
    ...                        size_packet=${size_packet_dl}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}
    ...                        linux_congestion=${linux_congestion_protocol}

[1][1.0] UL_Throughput_TCP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     2550 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_5cc_tcp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_tcp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}
    ...                                    linux_congestion_dl=${linux_congestion_protocol}

[1][1.0] DL_Throughput_UDP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp
    Set Test Variable    ${tput_dl}     2550 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_5cc_udp_dl}
    ...                        parallel_streams=${parallel_streams_dl_udp}
    ...                        size_packet=${size_packet_dl}
    ...                        buffer_client=${buffer_client_dl_udp}
    ...                        buffer_server=${buffer_server_dl_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] UL_Throughput_UDP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        buffer_client=${buffer_client_ul_udp}
    ...                        buffer_server=${buffer_server_ul_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_UDP_1-DRB_OTA_AWEUC_5CC_contiguous
    [Setup]    Test Setup for Configuration EP    5CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp
    Set Test Variable    ${tput_dl}     2550 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_5cc_udp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_udp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    buffer_client_dl=${buffer_client_dl_udp}
    ...                                    buffer_server_dl=${buffer_server_dl_udp}
    ...                                    buffer_client_ul=${buffer_client_ul_udp}
    ...                                    buffer_server_ul=${buffer_server_ul_udp}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] DL Throughput_TCP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     3050 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_6cc_tcp_dl}
    ...                        parallel_streams=${parallel_streams_dl_tcp}
    ...                        size_packet=${size_packet_dl}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}
    ...                        linux_congestion=${linux_congestion_protocol}

[1][1.0] UL_Throughput_TCP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     3050 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_6cc_tcp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_tcp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}
    ...                                    linux_congestion_dl=${linux_congestion_protocol}

[1][1.0] DL Throughput_UDP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp
    Set Test Variable    ${tput_dl}     3050 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_6cc_udp_dl}
    ...                        parallel_streams=${parallel_streams_dl_udp}
    ...                        size_packet=${size_packet_dl}
    ...                        buffer_client=${buffer_client_dl_udp}
    ...                        buffer_server=${buffer_server_dl_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] UL_Throughput_UDP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        buffer_client=${buffer_client_ul_udp}
    ...                        buffer_server=${buffer_server_ul_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_UDP_1-DRB_OTA_AWEUC_6CC_contiguous
    [Setup]    Test Setup for Configuration EP    6CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp
    Set Test Variable    ${tput_dl}     3050 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_6cc_udp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_udp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    buffer_client_dl=${buffer_client_dl_udp}
    ...                                    buffer_server_dl=${buffer_server_dl_udp}
    ...                                    buffer_client_ul=${buffer_client_ul_udp}
    ...                                    buffer_server_ul=${buffer_server_ul_udp}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] DL_Throughput_TCP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}                   tcp
    Set Test Variable    ${tput_dl}                    3500 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_tcp}    4

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_7cc_tcp_dl}
    ...                        parallel_streams=${parallel_streams_dl_tcp}
    ...                        size_packet=${size_packet_dl}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}
    ...                        linux_congestion=${linux_congestion_protocol}

[1][1.0] UL_Throughput_TCP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}                   tcp
    Set Test Variable    ${tput_dl}                    3500 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_tcp}    4

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_7cc_tcp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_tcp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}
    ...                                    linux_congestion_dl=${linux_congestion_protocol}

[1][1.0] DL_Throughput_UDP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp
    Set Test Variable    ${tput_dl}     3500 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_udp}    4

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_7cc_udp_dl}
    ...                        parallel_streams=${parallel_streams_dl_udp}
    ...                        size_packet=${size_packet_dl}
    ...                        buffer_client=${buffer_client_dl_udp}
    ...                        buffer_server=${buffer_server_dl_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] UL_Throughput_UDP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    udp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        buffer_client=${buffer_client_ul_udp}
    ...                        buffer_server=${buffer_server_ul_udp}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_UDP_1-DRB_OTA_AWEUC_7CC_contiguous
    [Setup]    Test Setup for Configuration EP    7CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}                   udp
    Set Test Variable    ${tput_dl}                    3500 Mbits/sec
    Set Test Variable    ${parallel_streams_dl_udp}    4

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_7cc_udp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_udp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    buffer_client_dl=${buffer_client_dl_udp}
    ...                                    buffer_server_dl=${buffer_server_dl_udp}
    ...                                    buffer_client_ul=${buffer_client_ul_udp}
    ...                                    buffer_server_ul=${buffer_server_ul_udp}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}

*** Keywords ***
Test Setup for Configuration EP
    [Arguments]    ${test_config}
    Run Keyword If    """${test_config}"""!="""${current_config}"""
    ...    Perform Full Commissioning on Classical gNB and Wait onAir    test_config=${test_config}
    Disable Beams on Main RU
    Common Preconditions

Perform Full Commissioning on Classical gNB and Wait onAir
    [Arguments]    ${test_config}
    Perform Full Commissioning on Classical gNB    prefix_tag=${test_config}
    Wait for onAir on all DUs
    Set Suite Variable    ${current_config}    ${test_config}

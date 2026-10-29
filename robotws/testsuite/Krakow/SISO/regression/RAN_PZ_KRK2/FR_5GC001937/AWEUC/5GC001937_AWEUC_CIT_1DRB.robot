*** Settings ***
Documentation
...   Test suite for regression testing of feature 5GC001937
...   author: Mateusz Jaskot
...   contact: mateusz.jaskot@nokia.com

Resource    ./Resources/Resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/DL_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/UL_Throughput_1-DRB_OTA/procedure.robot


Force Tags    STATE_ON_AIR    CIT    CDRT
...   PY36

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Common Test Teardown

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
${duration_8cc}                       1200s
${deviation_8cc_udp_dl}               2.5%
${deviation_8cc_tcp_dl}               2.5%
${parallel_streams_dl_tcp}            4
${parallel_streams_dl_udp}            2
${buffer_client_dl_udp}               32M
${buffer_server_dl_udp}               32M
${size_packet_dl}                     1400B
${size_packet_ul}                     1320B
${deviation_ul}                       12%
${tput_ul}                            250 Mbits/sec
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
[1][1.0] DL_Throughput_TCP_1-DRB_OTA_AWEUC_8CC_contiguous
    [Setup]    Common Preconditions With Commissioning    8CC_con_1DRB
    [Timeout]    50m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     4000 Mbits/sec

    DL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration_8cc}
    ...                        tput=${tput_dl}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_8cc_tcp_dl}
    ...                        parallel_streams=${parallel_streams_dl_tcp}
    ...                        size_packet=${size_packet_dl}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}
    ...                        linux_congestion=${linux_congestion_protocol}

[1][1.0] UL_Throughput_TCP_1-DRB_OTA_AWEUC_8CC_contiguous
    [Setup]    Common Preconditions With Commissioning    8CC_con_1DRB
    [Timeout]    50m
    Set Test Variable    ${protocol}    tcp

    UL_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                        duration=${duration_8cc}
    ...                        tput=${tput_ul}
    ...                        protocol=${protocol}
    ...                        deviation=${deviation_ul}
    ...                        parallel_streams=${parallel_streams_ul}
    ...                        size_packet=${size_packet_ul}
    ...                        interval=${interval}
    ...                        reboot_ue=${reboot_ue}
    ...                        timeout_reboot_ue=${timeout_reboot_ue}

[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_8CC_contiguous
    [Setup]    Common Preconditions With Commissioning    8CC_con_1DRB
    [Timeout]    50m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     4000 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration_8cc}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_8cc_tcp_dl}
    ...                                    deviation_ul=${deviation_ul}
    ...                                    parallel_streams_dl=${parallel_streams_dl_tcp}
    ...                                    parallel_streams_ul=${parallel_streams_ul}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    size_packet_ul=${size_packet_ul}
    ...                                    interval=${interval}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}
    ...                                    linux_congestion_dl=${linux_congestion_protocol}

[1][1.0] Bi-Directional_Throughput_UDP_1-DRB_OTA_AWEUC_8CC_contiguous
    [Setup]    Common Preconditions With Commissioning    8CC_con_1DRB
    [Timeout]    50m
    Set Test Variable    ${protocol}                udp
    Set Test Variable    ${tput_dl}                 4000 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}
    ...                                    duration=${duration_8cc}
    ...                                    tput_dl=${tput_dl}
    ...                                    tput_ul=${tput_ul}
    ...                                    protocol=${protocol}
    ...                                    deviation_dl=${deviation_8cc_udp_dl}
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

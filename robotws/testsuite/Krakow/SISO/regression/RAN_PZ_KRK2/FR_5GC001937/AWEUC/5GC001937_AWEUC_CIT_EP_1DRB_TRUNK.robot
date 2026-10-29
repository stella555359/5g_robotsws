*** Settings ***
Documentation
...   Test suite for CIT regression testing for trunk
...   author: Patryk Lamch, patryk.lamch@nokia.com
...   maintainer: Patryk Lamch, patryk.lamch@nokia.com

Resource    taf/rfrl/bts/robot/common/gnb_ru.robot
Resource    ./Resources/Resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py



Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=8CC
...               increase_timeout_for_update_sw=${1800}
Suite Teardown    Common Suite Teardown
Test Teardown     Common Test Teardown EP


*** Variables ***
${capabilities}                       REAL_UE
${duration_4cc}                       300s
${duration_8cc}                       1200s
${deviation_4cc_udp_dl}               4.8%
${deviation_4cc_tcp_dl}               4.8%
${deviation_8cc_udp_dl}               2.5%
${deviation_8cc_tcp_dl}               2.5%
${parallel_streams_dl_tcp}            4
${parallel_streams_dl_udp}            2
${buffer_client_dl_udp}               32M
${buffer_server_dl_udp}               32M
${size_packet_dl}                     0B
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
[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_4CC_contiguous
    [Setup]    Test Setup for Configuration EP    4CC_EP_con_1DRB
    [Timeout]    30m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     2050 Mbits/sec

    Bi-Directional_Throughput_1-DRB_OTA     capabilities=${capabilities}
    ...                                     duration=${duration_4cc}
    ...                                     tput_dl=${tput_dl}
    ...                                     tput_ul=${tput_ul}
    ...                                     protocol=${protocol}
    ...                                     deviation_dl=${deviation_4cc_tcp_dl}
    ...                                     deviation_ul=${deviation_ul}
    ...                                     parallel_streams_dl=${parallel_streams_dl_tcp}
    ...                                     parallel_streams_ul=${parallel_streams_ul}
    ...                                     size_packet_dl=${size_packet_dl}
    ...                                     size_packet_ul=${size_packet_ul}
    ...                                     interval=${interval}
    ...                                     reboot_ue=${reboot_ue}
    ...                                     linux_congestion_dl=${linux_congestion_protocol}
    ...                                     timeout_reboot_ue=${timeout_reboot_ue}


[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWEUC_8CC_contiguous
    [Setup]    Test Setup for Configuration EP    8CC_EP_con_1DRB
    [Timeout]    50m
    Set Test Variable    ${protocol}    tcp
    Set Test Variable    ${tput_dl}     4150 Mbits/sec

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


*** Keywords ***
Test Setup for Configuration EP
    [Arguments]    ${test_config}
    Run Keyword If    """${test_config}"""!="""${current_config}"""
    ...                   Perform Full Commissioning on Classical gNB and Wait onAir    test_config=${test_config}
    Disable Beams on Main RU
    @{allowed_alarms}    caa.get_default_allowed_alarms
    Set suite variable   @{allowed_alarms}
    Common Preconditions With Watching Alarms

Perform Full Commissioning on Classical gNB and Wait onAir
    [Arguments]    ${test_config}
    Perform Full Commissioning on Classical gNB    prefix_tag=${test_config}
    Wait for onAir on all DUs
    Set Suite Variable    ${current_config}    ${test_config}

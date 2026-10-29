*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009249
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com


Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${ENABLE_RACH_OBSERVER}                 ${False}    # don't set to True, the functionality doesn't work
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}    # to debug tput problems set to True
${protocol}    tcp
${tput_dl}    4340 Mbits/sec
${parallel_streams_dl}    4
${capabilities}    REAL_ANDROID_UE
${duration_8CC_1-DRB}    1200s
${deviation}     10%
${size_packet_dl}    1400B
${size_packet_ul}    1320B
${tput_ul}    500 Mbits/sec
${parallel_streams_ul}    2
${interval}    1
${reboot_ue}    True
${timeout_reboot_ue}    100
${linux_congestion}    reno


*** Test Cases ***
[1][1.0] Bi-Directional_Throughput_TCP_1-DRB_OTA_AWKUC_8CC_4CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities}    duration=${duration_8CC_1-DRB}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}
    ...    interval=${interval}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    linux_congestion_dl=${linux_congestion}

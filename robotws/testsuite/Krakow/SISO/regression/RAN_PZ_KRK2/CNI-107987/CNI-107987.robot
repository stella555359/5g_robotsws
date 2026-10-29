*** Settings ***
Documentation
...   Testsuite for regression testing of CNI-107987
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Wiktoria Janik, wiktoria.janik@nokia.com

Library     OperatingSystem
Library     taf.ue    WITH NAME    ue
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup      CNI-107987 Suite Setup
Suite Teardown   Common Suite Teardown
Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Variables ***
${DURATION}                              60s
${TPUT_DL}                               270 Mbits/sec
${TPUT_UL}                               74 Mbits/sec
${PROTOCOL}                              tcp
${DEVIATION_UL}                          10%
${DEVIATION_DL}                          5%
${PARALLEL_STREAMS_DL}                   4
${PARALLEL_STREAMS_UL}                   2
${SIZE_PACKET_DL}                        1400B
${SIZE_PACKET_UL}                        1330B
${INTERVAL}                              1
${LINUX_CONGESTION_PROTOCOL}             reno
${COLLECT_LOGS_DURING_DATA_TRANSFER}     ${False}
${ENABLE_RACH_OBSERVER}                  ${False}

*** Test Cases ***
[1][1.0] CNI-107987_General_SiSo_RU_module_reset_from_GUI
    General SiSo Auto RF module reset from WebUI    runs=1
    Reboot UE And Perform L3 Call

[1][1.0] CNI-107987_Manual_SiSo_SM_RF_Module_lock_unlock
    General SiSo Auto RF Lock Unlock
    Reboot UE And Perform L3 Call

[1][1.0] CNI-107987_General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock
    Reboot UE And Perform L3 Call

*** Keywords ***
Reboot UE And Perform L3 Call
   Reboot UE Before L3 Call
   Perform L3 call

CNI-107987 Suite Setup
   Common Suite Setup With OnAir Test Line Preparation
   ...    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
   ...    increase_timeout_for_update_sw=900
   @{allowed_alarms}    caa.get_default_allowed_alarms
   Set Suite Variable  @{allowed_alarms}
   Common Suite Setup

Reboot UE Before L3 Call
    [Arguments]    ${timeout_reboot_ue}=100  ${alias}=UE
    Require Ue For L3 Call
    ue.Reboot Ue    ${alias}    timeout=${timeout_reboot_ue}

Perform L3 call
    Verify L3 Call One Way Data Transfer    direction=DL
    ...                                     duration=${DURATION}
    ...                                     tput=${TPUT_DL}
    ...                                     protocol=${PROTOCOL}
    ...                                     deviation=${DEVIATION_DL}
    ...                                     parallel_streams=${PARALLEL_STREAMS_DL}
    ...                                     size_packet=${SIZE_PACKET_DL}
    ...                                     buffer_client=${None}
    ...                                     buffer_server=${None}
    ...                                     interval=${INTERVAL}
    ...                                     qci=${None}
    ...                                     linux_congestion=${LINUX_CONGESTION_PROTOCOL}

    Verify L3 Call One Way Data Transfer    direction=UL
    ...                                     duration=${DURATION}
    ...                                     tput=${TPUT_UL}
    ...                                     protocol=${PROTOCOL}
    ...                                     deviation=${deviation_ul}
    ...                                     parallel_streams=${PARALLEL_STREAMS_UL}
    ...                                     size_packet=${SIZE_PACKET_UL}
    ...                                     buffer_client=${None}
    ...                                     buffer_server=${None}
    ...                                     interval=${INTERVAL}
    ...                                     qci=${None}
    ...                                     linux_congestion=${LINUX_CONGESTION_PROTOCOL}

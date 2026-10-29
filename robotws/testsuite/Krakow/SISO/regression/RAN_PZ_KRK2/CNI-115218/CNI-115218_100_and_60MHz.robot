*** Settings ***
Documentation
...   Testsuite for regression testing of CNI-115218
...   author: Wiktoria Janik, wiktoria.janik@nokia.com
...   maintainer: Wiktoria Janik, wiktoria.janik@nokia.com

Library     OperatingSystem
Library     taf.ue    WITH NAME    ue
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./Resources/CNI-115218_resources.py


Suite Setup      CNI-115218 Suite Setup
Suite Teardown   Common Suite Teardown
Test Setup       CNI-115218 Test Setup
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
${DURATION}                              120s
${TPUT_DL}                               780 Mbits/sec
${TPUT_UL}                               60 Mbits/sec
${PROTOCOL}                              tcp
${DEVIATION_UL}                          10%
${DEVIATION_DL}                          12%
${PARALLEL_STREAMS_DL}                   8
${PARALLEL_STREAMS_UL}                   8
${SIZE_PACKET_DL}                        1400B
${SIZE_PACKET_UL}                        1330B
${INTERVAL}                              1
${LINUX_CONGESTION_PROTOCOL}             reno
${COLLECT_LOGS_DURING_DATA_TRANSFER}     ${False}
${ENABLE_RACH_OBSERVER}                  ${False}
${DIST_NAME}                             MRBTS-76093/NRBTS-76093/NRCELL-0
${PARAM_NAME}                            qRxLevMin
${PARAM_VALUE}                           -22
@{CUSTOM_ALLOWED_ALARMS}                 Unit power reset    No connection to unit

*** Test Cases ***
[1][1.0] CNI-115218_Manual_SiSo_SM_RF_Module_lock_unlock
    General SiSo Auto RF Lock Unlock
    Perform L3 Call

[1][1.0] CNI-115218_Manual_SiSo_SM_BTS_Site_Reset
    General SiSo Auto gNB Site Reset From WebUI
    Perform L3 Call

[1][1.0] CNI-115218_Manual_SiSo_REC_Radio_Module_power_reset
    [Setup]       Run Keywords    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}
    ...           AND    CNI-115218 Test Setup
    ...           AND    Set test variable    @{mandatory_alarms}    10
    ...           AND    Set test variable    @{mandatory_alarms_after_power_on}    4589
    General SiSo Auto RF module power reset    mandatory_alarms=@{mandatory_alarms}
    ...                                        mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}
    Perform L3 Call

*** Keywords ***
CNI-115218 Test Setup
    Common Preconditions With Watching Alarms
    Trigger online parameter change      ${DIST_NAME}      ${PARAM_NAME}      ${PARAM_VALUE}

CNI-115218 Suite Setup
   Common Suite Setup With OnAir Test Line Preparation
   ...    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
   ...    increase_timeout_for_update_sw=900
   ...    prefix_tag=CNI-115218
   @{allowed_alarms}    caa.get_default_allowed_alarms
   Set Suite Variable  @{allowed_alarms}
   Common Suite Setup

Perform L3 call
    Require Ue For L3 Call
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

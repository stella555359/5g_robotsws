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
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./Resources/CNI-115218_resources.py


Suite Setup      CNI-115218 Suite Setup
Suite Teardown   Common Suite Teardown
Test Setup       CNI-115218 Test Setup
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
${DURATION}                              120s
${TPUT_DL}                               1000 Mbits/sec
${TPUT_UL}                               85 Mbits/sec
${PROTOCOL}                              tcp
${DEVIATION_UL}                          10%
${DEVIATION_DL}                          10%
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


*** Test Cases ***
[1][1.0] CNI-115218_Cell_recommissioning_from_100_and_60MHz_to_80_and_80_MHz_with_bidi_L3_call
    Perform Delta Commissioning On gNB
    ...             delta=${delta_scf}
    Wait Until Keyword Succeeds     300 sec     15 sec    gnbcell.Verify All Cells are OnAir
    Perform L3 Call

[1][1.0] CNI-115218_General_SiSo_RU_module_reset_from_GUI
    General_SiSo_Auto_RU_Module_Reset_From_GUI
    Perform L3 Call

[1][1.0] CNI-115218_General_SiSo_Cell_block_and_unblock
    [Setup]       Run Keywords    CNI-115218 Test Setup
    ...           AND    Trigger online parameter change    MRBTS-76093/NRBTS-76093
    ...           actEnhancedNgRanSupport
    ...           false
    General SiSo Cell block and unblock
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

General_SiSo_Auto_RU_Module_Reset_From_GUI
    Reset All gNB Radio Units from GUI
    Sleep    90s    reason=Wait for RU and cell status change after reboot
    Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir

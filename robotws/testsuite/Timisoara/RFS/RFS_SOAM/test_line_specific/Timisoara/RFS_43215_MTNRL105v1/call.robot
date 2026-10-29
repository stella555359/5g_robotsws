*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    158985735 158985736 158985737
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    30 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    500 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    10 Mbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order




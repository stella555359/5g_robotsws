*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_8150}   alarmId=7115   faultId=8150
${CNI_127210_ENABLED}    ${True}

*** Test Cases ***
[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0
    ...    AND    Append To List  ${SBTS_TEMP_CRITICAL_ALARMS}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown




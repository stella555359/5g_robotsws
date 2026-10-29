*** Settings ***
Documentation    Robot Test Suite 2
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    REAL_ANDROID_UE_2 REAL_ANDROID_UE_3 REAL_ANDROID_UE_4 REAL_ANDROID_UE_5
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS1 BTS1 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;11930
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


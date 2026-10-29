*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.robot
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL37    SBTS00    STATE_SKIP_AGENT    CRT


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_primary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    25
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    6000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    3000
    ...    AND    Set Test Variable    ${Link_break_duration}    9000
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    EA200150649,EA212650486
    ...    AND    Set Test Variable    ${PM_Counters_Check}    True
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    200 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    600 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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


[2]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    200 kbits/sec
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



[1][3.0] Long secondary link break_CB007447
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    25
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    6000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    3000
    ...    AND    Set Test Variable    ${Link_break_duration}    9000
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    EA200150649,EA212650486
    ...    AND    Set Test Variable    ${PM_Counters_Check}    True
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order

*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.robot
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL37    SBTS26R1    STATE_SKIP_AGENT    CRT


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_primary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
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


[1][3.0] Long secondary link break_CB007447
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    6000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    3000
    ...    AND    Set Test Variable    ${Link_break_duration}    12000
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


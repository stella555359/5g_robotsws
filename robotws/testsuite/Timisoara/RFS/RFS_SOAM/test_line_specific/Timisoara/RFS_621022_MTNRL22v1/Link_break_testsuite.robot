*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}   ${FALSE}
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***
[1]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_primary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    2000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    1900
    ...    AND    Set Test Variable    ${Link_break_duration}    5000
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_primary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    2000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    1900
    ...    AND    Set Test Variable    ${Link_break_duration}    500
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    2000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    1900
    ...    AND    Set Test Variable    ${Link_break_duration}    5000
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    2000
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    1900
    ...    AND    Set Test Variable    ${Link_break_duration}    500
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_primary_link_break_reset_recovery_cb007447.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    2000
    ...    AND    Set Test Variable    ${Link_break_duration}    15000
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${PM_Counters_Check}    True
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
    [Timeout]    12h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_rmod_secondary_link_break_cb013082.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    160
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    6Q190128945, K9182544304, BL2330H60B5
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${RTWP_CHECK}    False
    ...    AND    Set Test Variable    ${LONG_FIBER_PORTS}    2.4.1-2.4.2

    ...    AND    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_RMOD_Secondary_Link_Break_CB013082.TC Teardown
    ...    AND    Restore Resource Search Order
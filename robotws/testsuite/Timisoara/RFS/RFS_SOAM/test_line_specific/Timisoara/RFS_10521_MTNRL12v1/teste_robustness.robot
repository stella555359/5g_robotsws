*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_cb007447_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_RESET}    BOTH
    ...    AND    Set Test Variable    ${KPI_LIST}    kpi1b
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR_LIST}    950
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR_LIST}    950
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    200
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    100
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    920
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    1200
    ...    AND    Set Test Variable    ${PM_Counters_Check}    True
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False

    ...    AND    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    TC__SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__common_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Teardown
    ...    AND    Restore Resource Search Order


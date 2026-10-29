*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    72000
    Set Test Variable    ${runs}    3
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
        ...    AND    Set Test Variable    ${BTS_LIST}    ALL
        ...    AND    Set Test Variable    ${KPI_LIST}    kpi1a
        ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
        ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
        ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
        ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
        ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}    BTS1
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
        ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
        ...    AND    Set Test Variable    ${PM_Counters_Check}    False
        ...    AND    Set Test Variable    ${cpriSyncBreakTime}    500
        ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    400
        ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30

        ...    AND    Set Test Variable    ${runs}    3
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
        ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    END
    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Timeout]    72000
    Set Test Variable    ${runs}    3
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_without_ru_reset_cb012446_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
        ...    AND    Set Test Variable    ${BTS_LIST}    ALL
        ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTimeSite}    300
        ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
        ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
        ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
        ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
        ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
        ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
        ...    AND    Set Test Variable    ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}

        ...    AND    Set Test Variable    ${runs}    3
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
        ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Teardown
    END
    Restore Resource Search Order

*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}  ${True}
&{ADD_NR_IGNORED_ALARM1}    alarmId=7107    faultId=7308
&{ADD_NR_IGNORED_ALARM2}    alarmId=7107    faultId=7319

*** Test Cases ***
[1]NR_NR__STATE__NR_RM_Reset_from_WEBEM
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    15
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    300
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_NR_IGNORED_ALARM1}  ${ADD_NR_IGNORED_ALARM2}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_NR_IGNORED_ALARM1}  ${ADD_NR_IGNORED_ALARM2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


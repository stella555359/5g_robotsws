*** Settings ***
Documentation
...   author: Valentin Marian
...   maintainer: valentin.marian@nokia.com

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL76_1
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***


[1]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB007447_RMOD_SN}
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB012446_RMOD_SN}
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
    ...    AND    Set Test Variable    ${PM_Counters_Check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order
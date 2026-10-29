*** Settings ***
Documentation
...   author: Carla-Iazmina Urezeanu
...   maintainer: carla-iazmina.urezeanu@nokia.com

Resource    ../../../test_resources/SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL109
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***
[1]SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rmod_high_temp_alarm_and_counters_check_cb011167.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    L1244506718
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    ${True}
    ...    AND    Set Test Variable    ${USER_RSI_INFO_COLLECT}     ${True}
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    480
    ...    AND    Set Test Variable    ${PM_Counters_Check}         ${True}
    ...    AND    Set Test Variable    ${PM_INTERVAL}               15
    ...    AND    SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
    TC__SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167.TC Teardown
    ...    AND    Restore Resource Search Order

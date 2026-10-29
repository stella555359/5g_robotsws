*** Settings ***
Documentation    Testsuite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
${USER_SCF_VALIDATION_CHECK}    ${False}
${USER_RTWP_CHECK}    ${False}
${USER_STOP_AND_FIX}    ${False}
&{Ignored_alarm_diagnostic}   faultId=6450  alarmId=7115
&{Ignored_alarm_NRRELNotConfiguredA3A5}   faultId=8150  alarmId=7115
&{Ignored_alarm_SW}  faultId=7115  alarmId=4590


*** Test Cases ***
[1]NRL__STATE__NR_BBMOD_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    900
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    2900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}     240
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    ${True}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${Ignored_alarm_diagnostic}  ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${Ignored_alarm_diagnostic}  ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET_CNI_127210}  ${Ignored_alarm_diagnostic}
    ...    ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET_CNI_127210}  ${Ignored_alarm_diagnostic}
    ...    ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order

[1]NRL__STATE__LTE_BBMOD_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    900
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    2900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}     240
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    ${True}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${Ignored_alarm_diagnostic}  ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${Ignored_alarm_diagnostic}  ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET_CNI_127210}  ${Ignored_alarm_diagnostic}
    ...    ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET_CNI_127210}  ${Ignored_alarm_diagnostic}
    ...    ${Ignored_alarm_NRRELNotConfiguredA3A5}
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order
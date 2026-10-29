*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_4459}    alarmId=7220    faultId=4459


*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    295
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    295
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    295
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_DURING_RESET}  ${ADD_IGNORED_ALARM_4459}
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order

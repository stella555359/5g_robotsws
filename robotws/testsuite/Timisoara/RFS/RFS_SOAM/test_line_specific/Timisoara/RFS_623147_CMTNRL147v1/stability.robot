*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/CBTS_SBTS__LOGS__Stability.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rinline_rmod_link_break_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBERS}
    ...    AND    Set Test Variable    ${RMOD_RINLINE_Calient_Crossconnections}     2.5.2-2.5.1;2.5.4-2.5.3;2.5.5-2.5.6
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    240

    ...    AND    CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break
    TC__CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RINLINE_RMOD_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CBTS_SBTS__LOGS__Stability
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    180
    ...    AND    Set Test Variable    ${CHECK_INTERVAL}    1
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_CBTS}    True
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_SBTS}    True
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4}    Current

    ...    AND    CBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    CBTS_SBTS__LOGS__Stability
    TC__CBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    CBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order

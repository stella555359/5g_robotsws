*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/CBTS_SBTS__LOGS__Stability.robot

*** Variables ***
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

*** Test Cases ***
[1]CBTS_SBTS__LOGS__Stability
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    120
    ...    AND    Set Test Variable    ${CHECK_INTERVAL}    30
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


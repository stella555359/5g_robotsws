*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables


*** Test Cases ***
[1]SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__commissioning_of_cacv_parameters_cb013031_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_YAML_PARAMETERS_PATH}    RFS_43164_MTNRL49v1/cacv_parameters.yaml

    ...    AND    SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
    TC__SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
    [Teardown]    Run Keywords    SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031.TC Teardown
    ...    AND    Restore Resource Search Order

*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]UUF_SW_UPGRADE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS25R1_ENB_0000_000524_000000
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS25R1_ENB_0000_000524_000000
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_250111_000010
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS25R1_ENB_0000_000530_000000
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    1815,4773,1898
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}    1815,4773,1898
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4655,4654,61652,61649,61524,1898
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4655,4654,61652,61649,61524,1898
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    TMO US
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03
    ...    AND    UUF_SW_UPGRADE.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE
    TC__UUF_SW_UPGRADE
    [Teardown]    Run Keywords    UUF_SW_UPGRADE.TC Teardown
    ...    AND    Restore Resource Search Order

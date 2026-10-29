*** Settings ***
Documentation
    ...  This testsuite was created for CRT runs.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1708

*** Test Cases ***
[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered_8
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHLOA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order

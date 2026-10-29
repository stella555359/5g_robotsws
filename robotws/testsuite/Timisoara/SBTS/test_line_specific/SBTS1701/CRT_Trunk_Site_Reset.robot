*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_1ASIA_3ABIA_2FRGY_2FXDB_1AHEB
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***

[1]Automated__FM__Site_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__Site_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_exceeded
    TC__FM__Site_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

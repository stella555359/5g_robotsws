*** Settings ***
Force Tags  QCD_MN_RAN QCP_RAN_ST SBTS22R1 SRAN CLOUD_SRAN_LWG_1ASIA_2ABIA_1ASIA_3ABIA_2FRGY_2FXDB_1AHEB STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***
[1][1.1] Automated__SWM__SCF_validation_errors_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

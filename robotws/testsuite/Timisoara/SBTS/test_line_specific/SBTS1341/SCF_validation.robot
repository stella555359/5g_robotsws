*** Settings ***
Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SRAN  CLOUD_SRAN_WG_10341_1FSMF_1FXDB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_18_UTESRANCLOUD1341/node1/BTS_CLOUD_SRAN_WG_10341_1FSMF_1FXDB_SBTS00.xml

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

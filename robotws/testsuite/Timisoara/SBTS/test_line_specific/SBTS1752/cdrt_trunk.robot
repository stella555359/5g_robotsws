*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup      Set Library Search Order  ute_admin   taf.gnb.oam.coam.admin
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Radio_Reset.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_Radio_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RESETTYPE}    Hard
    
    ...    AND    WebEM__Admin_CLI_Radio_Reset.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Radio_Reset
    TC__WebEM__Admin_CLI_Radio_Reset
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Radio_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

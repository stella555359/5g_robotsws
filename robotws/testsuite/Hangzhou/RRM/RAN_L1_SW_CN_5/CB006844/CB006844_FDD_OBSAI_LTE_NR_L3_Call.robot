*** Settings ***
Documentation
...    Author:  claire.gao@nokia-sbell.com

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49    Cell blocked
${scfc_file}         CB006844_ABIO_3xFRHG_LTEFDD_NRFDD_4xNRCEL_5xLNCEL.xml
${5G_Cell_id_first}    180125699
${4G_Global_Cell_id_first}    11
${commission_succeed}    False

*** Test Cases ***
CB006844_A_TC19_NR_FR1_FDD_OBSAI_ABIO_20MHz_4T4R_L3call
    [Tags]    LOKI    CB006844    CB006844_US19    ASIB+ABIO    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB006844${/}CB006844_ABIO_3xFRHG_LTEFDD_NRFDD_4xNRCEL_5xLNCEL.xml
    Perform 4G Cell block 12 via AdminCLI
    Perform NR Cell block 1,3 via AdminCLI
    SMAwave L3 call    ${4G_Global_Cell_id_first}    110M    48M    10%    4G    7
    Perform 4G Cell block 11 via AdminCLI
    Perform NR Cell Unblock 3 via AdminCLI
    SMAwave L3 call    ${5G_Cell_id_first}    180M    70M    10%    5G    7
    Perform 4G Cell unblock 11,12 via AdminCLI
    Perform NR Cell Unblock 1 via AdminCLI


*** Keywords ***
modify_scfc_and_perform_full_commission
    ${scfc_path}=    Set Variable    ${CURDIR}${/}..${/}resources${/}configuration_file${/}CB006844${/}${scfc_file}
    ${commission_succeed}=    Run Keyword And Return Status    Full Commission gNB SCFC and wait for onair    ${scfc_path}
    Set Suite Variable    ${commission_succeed}
    Should Be True    ${commission_succeed}    [ERROR] The recommission is failed.
